import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/track_dao.dart';
import '../../data/models/track.dart';
import '../track_resolver/models/resolved_track.dart';
import 'download_queue.dart';
import '../../core/constants/app_credentials.dart';
import '../../core/constants/app_constants.dart';
import 'models/download_task.dart';

/// Handles the actual file download + metadata writing.
///
/// Flow for each track:
///   1. Pull next batch from DownloadQueue
///   2. Download audio file via Dio with progress
///   3. Fetch artwork (remote URL → local jpg)
///   4. Write ID3 tags via metadata_god
///   5. Mark track as done in DB
///   6. Fire a local notification
class DownloadService {
  final DownloadQueue   _queue;
  final TrackDao        _trackDao;
  final Dio             _dio;
  final FlutterLocalNotificationsPlugin _notifs;

  bool _isRunning = false;

  // artwork fallback sources tried in order
  static const _artworkSources = [
    _ArtworkSource.trackUrl,     // already on the DecodedTrack
    _ArtworkSource.coverArtArchive,
    _ArtworkSource.itunes,
    _ArtworkSource.lastFm,
  ];

  DownloadService({
    required AppDatabase db,
    required DownloadQueue queue,
    Dio? dio,
    FlutterLocalNotificationsPlugin? notifs,
  })  : _queue    = queue,
        _trackDao = TrackDao(db),
        _dio      = dio ?? Dio(),
        _notifs   = notifs ?? FlutterLocalNotificationsPlugin();

  // ── Public API ────────────────────────────────────────────────────────────

  /// Download a single track immediately (tap on track row).
  Future<void> downloadOne(ResolvedTrack resolved) async {
    final task = await _queue.enqueue(resolved);
    await _processTask(task);
  }

  /// Download a whole playlist — queues all, then processes.
  Future<void> downloadPlaylist(List<ResolvedTrack> resolved) async {
    await _queue.enqueueAll(resolved);
    if (!_isRunning) await _processQueue();
  }

  /// Start processing whatever is in the queue.
  Future<void> resumeQueue() async {
    if (_isRunning) return;
    await _processQueue();
  }

  // ── Queue processor ───────────────────────────────────────────────────────

  Future<void> _processQueue() async {
    _isRunning = true;

    while (true) {
      final batch = await _queue.nextBatch();
      if (batch.isEmpty) break;

      // run up to maxConcurrent downloads in parallel
      await Future.wait(batch.map(_processTask));
    }

    _isRunning = false;
  }

  Future<void> _processTask(DownloadTask task) async {
    await _queue.markDownloading(task.id);
    await _trackDao.patch(task.trackId, {
      'download_status': DownloadStatus.downloading.name,
      'download_progress': 0,
    });

    try {
      // 1 — resolve output path
      final outputPath = await _buildOutputPath(task.trackId);

      // 2 — download audio
      await _downloadAudio(
        url:        task.resolvedUrl,
        outputPath: outputPath,
        taskId:     task.id,
        trackId:    task.trackId,
      );

      // 3 — fetch track record (for title/artist/artworkUrl)
      final track = await _trackDao.findById(task.trackId);
      if (track == null) throw Exception('Track not found: ${task.trackId}');

      // 4 — fetch artwork
      final artworkPath = await _fetchArtwork(track);

      // 5 — write ID3 tags
      await _writeTags(
        filePath:    outputPath,
        track:       track,
        artworkPath: artworkPath,
      );

      // 6 — mark done
      await _trackDao.markDownloaded(
        task.trackId,
        localFilePath:    outputPath,
        artworkLocalPath: artworkPath,
      );
      await _queue.markDone(task.id);

      // 7 — notify user
      await _showDoneNotification(track.title, track.artist);
    } catch (e) {
      await _queue.markFailed(task.id);
      await _trackDao.markFailed(task.trackId);
      await _queue.incrementRetries(task.id);
    }
  }

  // ── Audio download ────────────────────────────────────────────────────────

  Future<void> _downloadAudio({
    required String url,
    required String outputPath,
    required String taskId,
    required String trackId,
  }) async {
    await _dio.download(
      url,
      outputPath,
      onReceiveProgress: (received, total) async {
        if (total <= 0) return;
        final progress = ((received / total) * 100).toInt();
        await _trackDao.updateProgress(trackId, progress);
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
  }

  // ── Output path ───────────────────────────────────────────────────────────

  Future<String> _buildOutputPath(String trackId) async {
    final dir = await _audioDirectory();
    return p.join(dir.path, '$trackId.mp3');
  }

  Future<Directory> _audioDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir  = Directory(p.join(base.path, 'wavr', 'audio'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ── Artwork ───────────────────────────────────────────────────────────────

  Future<String?> _fetchArtwork(Track track) async {
    for (final source in _artworkSources) {
      final url = await _artworkUrl(source, track);
      if (url == null) continue;

      try {
        final artworkPath = await _buildArtworkPath(track.id);
        final res = await _dio.download(
          url,
          artworkPath,
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(seconds: 15),
          ),
        );
        if (res.statusCode == 200) return artworkPath;
      } catch (_) {
        continue; // try next source
      }
    }
    // generate placeholder gradient — saved as a small PNG
    return _generatePlaceholder(track);
  }

  Future<String?> _artworkUrl(_ArtworkSource source, Track track) async {
    switch (source) {
      case _ArtworkSource.trackUrl:
        return track.artworkUrl;

      case _ArtworkSource.coverArtArchive:
        // MusicBrainz / Cover Art Archive — free, no key
        try {
          final query = Uri.encodeComponent(
              '${track.artist} ${track.album ?? track.title}');
          final res = await _dio.get(
            '${AppConstants.musicBrainzBase}/release/?query=$query&fmt=json&limit=1',
            options: Options(headers: {
              'User-Agent': AppCredentials.musicBrainzUserAgent,
            }),
          );
          final releases = res.data['releases'] as List?;
          if (releases == null || releases.isEmpty) return null;
          final mbid = releases.first['id'] as String?;
          if (mbid == null) return null;
          return '${AppConstants.coverArtBase}/$mbid/front-500';
        } catch (_) {
          return null;
        }

      case _ArtworkSource.itunes:
        try {
          final query = Uri.encodeComponent('${track.artist} ${track.title}');
          final res   = await _dio.get(
            '${AppConstants.itunesApiBase}/search?term=$query&media=music&limit=1',
          );
          final results = res.data['results'] as List?;
          if (results == null || results.isEmpty) return null;
          return (results.first['artworkUrl100'] as String?)
              ?.replaceAll('100x100', '600x600');
        } catch (_) {
          return null;
        }

      case _ArtworkSource.lastFm:
        // Last.fm API — free tier, register at last.fm/api
        // replace with your key

        final apiKey = AppCredentials.lastFmApiKey;
        try {
          final res = await _dio.get(
            '${AppConstants.lastFmBase}/',
            queryParameters: {
              'method':  'track.getInfo',
              'api_key': apiKey,
              'artist':  track.artist,
              'track':   track.title,
              'format':  'json',
            },
          );
          final images =
              res.data['track']?['album']?['image'] as List?;
          if (images == null || images.isEmpty) return null;
          // last image in the array is the largest
          return images.last['#text'] as String?;
        } catch (_) {
          return null;
        }
    }
  }

  Future<String> _buildArtworkPath(String trackId) async {
    final base = await getApplicationDocumentsDirectory();
    final dir  = Directory(p.join(base.path, 'wavr', 'artwork'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return p.join(dir.path, '$trackId.jpg');
  }

  /// Generates a tiny solid-color JPEG as a placeholder.
  /// Color is derived from the track title — deterministic
  /// so the same track always gets the same color.
  Future<String?> _generatePlaceholder(Track track) async {
    try {
      final path = await _buildArtworkPath(track.id);
      final file = File(path);

      // simple 1x1 pixel JPEG — enough to avoid null artwork
      // the UI will render a gradient tile over it anyway
      final color = _colorFromString(track.title);
      final bytes = _buildMinimalJpeg(color);
      await file.writeAsBytes(bytes);
      return path;
    } catch (_) {
      return null;
    }
  }

  int _colorFromString(String s) {
    var hash = 0;
    for (final c in s.codeUnits) {
      hash = c + ((hash << 5) - hash);
    }
    return hash & 0xFFFFFF;
  }

  /// Returns a minimal valid JPEG byte sequence.
  /// Not a real image — just enough bytes to satisfy
  /// metadata_god when embedding artwork.
  List<int> _buildMinimalJpeg(int rgbColor) {
    final r = (rgbColor >> 16) & 0xFF;
    final g = (rgbColor >> 8) & 0xFF;
    final b = rgbColor & 0xFF;

    // minimal 1x1 JPEG with the given color
    return [
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00,
      0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB,
      0x00, 0x43, 0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07,
      0x07, 0x07, 0x09, 0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B,
      0x0B, 0x0C, 0x19, 0x12, 0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E,
      0x1D, 0x1A, 0x1C, 0x1C, 0x20, 0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C,
      0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29, 0x2C, 0x30, 0x31, 0x34, 0x34,
      0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32, 0x3C, 0x2E, 0x33, 0x34,
      0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01, 0x00, 0x01, 0x01,
      0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00, 0x01, 0x05,
      0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
      0x09, 0x0A, 0x0B, 0xFF, 0xC4, 0x00, 0xB5, 0x10, 0x00, 0x02, 0x01,
      0x03, 0x03, 0x02, 0x04, 0x03, 0x05, 0x05, 0x04, 0x04, 0x00, 0x00,
      0x01, 0x7D, 0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21,
      0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14, 0x32,
      0x81, 0x91, 0xA1, 0x08, 0x23, 0x42, 0xB1, 0xC1, 0x15, 0x52, 0xD1,
      0xF0, 0x24, 0x33, 0x62, 0x72, 0x82, 0x09, 0x0A, 0x16, 0x17, 0x18,
      0x19, 0x1A, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x34, 0x35, 0x36,
      0x37, 0x38, 0x39, 0x3A, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49,
      0x4A, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x63, 0x64,
      0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x73, 0x74, 0x75, 0x76, 0x77,
      0x78, 0x79, 0x7A, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A,
      0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0xA2, 0xA3,
      0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xB2, 0xB3, 0xB4, 0xB5,
      0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7,
      0xC8, 0xC9, 0xCA, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9,
      0xDA, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA,
      0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFF,
      0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00, r, g, b,
      0xFF, 0xD9,
    ];
  }

  // ── ID3 Tags ──────────────────────────────────────────────────────────────

  Future<void> _writeTags({
    required String  filePath,
    required Track   track,
    String?          artworkPath,
  }) async {
    try {
      List<int>? artworkBytes;
      if (artworkPath != null) {
        final f = File(artworkPath);
        if (await f.exists()) artworkBytes = await f.readAsBytes();
      }

      await MetadataGod.writeMetadata(
        file: filePath,
        metadata: Metadata(
          title:       track.title,
          artist:      track.artist,
          album:       track.album,
          year:        track.year,
          trackNumber: track.trackNumber,
          picture: artworkBytes != null
              ? Picture(
                  data:     Uint8List.fromList(artworkBytes),
                  mimeType: 'image/jpeg',
                )
              : null,
        ),
      );
    } catch (_) {
      // tag writing failure is non-fatal
      // the audio file is still usable
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<void> initNotifications() async {
    await _notifs.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  Future<void> _showDoneNotification(String title, String artist) async {
    const androidDetails = AndroidNotificationDetails(
      'wavr_downloads',
      'Downloads',
      channelDescription: 'Track download notifications',
      importance:  Importance.low,
      priority:    Priority.low,
      playSound:   false,
    );
    const iosDetails = DarwinNotificationDetails(presentSound: false);

    await _notifs.show(
      id: title.hashCode,
      title: '✓ Downloaded',
      body: '$title — $artist',
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS:     iosDetails,
      ),
    );
  }
}

enum _ArtworkSource {
  trackUrl,
  coverArtArchive,
  itunes,
  lastFm,
}
