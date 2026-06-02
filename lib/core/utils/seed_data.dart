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
  static Future<void> seedTestTrack(AppDatabase db) async {
    try {
      // copy asset to local storage
      final dir   = await getApplicationDocumentsDirectory();
      final dest  = p.join(dir.path, 'wavr', 'audio', 'test.mp3');
      await Directory(p.dirname(dest)).create(recursive: true);

      final bytes = await rootBundle.load('assets/audio/test.mp3');
      await File(dest).writeAsBytes(bytes.buffer.asUint8List());

      // insert track into DB
      final dao = TrackDao(db);
      final track = Track(
        id:             const Uuid().v4(),
        title:          'Discover',
        artist:         'Wavr',
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


    static Future<void> requestStoragePermission() async {
    // Android 13+ uses READ_MEDIA_AUDIO instead of READ_EXTERNAL_STORAGE
    if (await Permission.audio.isGranted) return;
    await Permission.audio.request();
    // fallback for older Android
    if (!await Permission.audio.isGranted) {
        await Permission.storage.request();
    }
    }

    static Future<List<String>> scanLocalAudio() async {
    final List<String> found = [];
    final scanDirs = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/WhatsApp/Media/WhatsApp Audio',
        '/storage/emulated/0/Telegram/Telegram Audio',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Ringtones',
    ];

    for (final path in scanDirs) {
        final dir = Directory(path);
        if (!await dir.exists()) continue;
        await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (['.mp3', '.m4a', '.flac', '.wav', '.aac', '.ogg']
                .contains(ext)) {
            found.add(entity.path);
            }
        }
        }
    }
    return found;
    }
}
