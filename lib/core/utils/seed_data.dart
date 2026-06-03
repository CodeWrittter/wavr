import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/track_dao.dart';
import '../../data/models/track.dart';

class SeedData {
  static const _audioExtensions = [
    '.mp3', '.m4a', '.flac', '.wav',
    '.aac', '.ogg', '.opus', '.wma',
  ];

  static Future<void> requestStoragePermission() async {
    // Android 13+ uses READ_MEDIA_AUDIO
    final audioStatus = await Permission.audio.request();
    if (audioStatus.isDenied) {
      // fallback for Android < 13
      await Permission.storage.request();
    }
    // if permanently denied, open settings
    if (await Permission.audio.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  static Future<void> seedTestTrack(AppDatabase db) async {
    try {
      final dir   = await getApplicationDocumentsDirectory();
      final dest  = p.join(dir.path, 'wavr', 'audio', 'Alan Walker - Fade.mp3');
      await Directory(p.dirname(dest)).create(recursive: true);

      // only copy if not already there
      if (!await File(dest).exists()) {
        final bytes = await rootBundle.load('assets/audio/Alan Walker - Fade.mp3');
        await File(dest).writeAsBytes(bytes.buffer.asUint8List());
      }

      // insert track into DB
      final dao = TrackDao(db);
      final track = Track(
        id:             const Uuid().v4(),
        title:          'Fade [NCS Release]',
        artist:         'Alan Walker',
        source:         TrackSource.local,
        localFilePath:  dest,
        downloadStatus: DownloadStatus.done,
        addedAt:        DateTime.now(),
      );
      await dao.insert(track);
    } catch (e) {
      // non-fatal — app still works without seed
    }
  }

  /// Scans the entire accessible storage for audio files.
  /// [onProgress] fires with (count, currentPath) as files are found.
  static Future<List<String>> scanWholeStorage({
    void Function(int count, String current)? onProgress,
  }) async {
    final found = <String>[];

    // roots to scan
    final roots = <Directory>[];

    // primary external storage
    final primary = Directory('/storage/emulated/0');
    if (await primary.exists()) roots.add(primary);

    // secondary storage (SD card etc)
    try {
      final external = await getExternalStorageDirectories();
      if (external != null) {
        for (final dir in external) {
          // walk up to the SD card root
          var current = dir;
          while (current.path.contains('/Android')) {
            current = current.parent;
          }
          if (!roots.any((r) => r.path == current.path)) {
            roots.add(current);
          }
        }
      }
    } catch (_) {}

    for (final root in roots) {
      await _scanDir(
        root,
        found,
        onProgress: onProgress,
      );
    }

    return found;
  }

  static Future<void> _scanDir(
    Directory dir,
    List<String> found, {
    void Function(int, String)? onProgress,
    // skip system/hidden folders
    Set<String> skip = const {
      'Android', '.', 'data', 'obb',
      'proc', 'sys', 'dev', 'cache',
    },
  }) async {
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is Directory) {
          final name = p.basename(entity.path);
          if (skip.any((s) => name.startsWith(s))) continue;
          await _scanDir(entity, found, onProgress: onProgress);
        } else if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (_audioExtensions.contains(ext)) {
            found.add(entity.path);
            onProgress?.call(found.length, entity.path);
          }
        }
      }
    } catch (_) {
      // permission denied on some dirs — skip silently
    }
  }
}
