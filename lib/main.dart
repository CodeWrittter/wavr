import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path/path.dart' as p;
// import 'package:metadata_god/metadata_god.dart';
import 'package:uuid/uuid.dart';
import 'app.dart';
import 'data/database/app_database.dart';
import 'data/database/daos/track_dao.dart';
import 'data/models/track.dart';
import 'services/download/download_service.dart';
import 'services/download/download_queue.dart';
import 'core/utils/first_launch.dart';
import 'core/utils/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: WavrApp(),
    ),
  );

  _performStartupTasks();
}

Future<void> _performStartupTasks() async {
  final db    = AppDatabase();
  final queue = DownloadQueue(db: db);
  final svc   = DownloadService(db: db, queue: queue);

  try {
    // init metadata_god (required before any tag read/write)
    // MetadataGod.initialize();
    
    await JustAudioBackground.init(
      androidNotificationChannelId:   'com.wavr.app.channel.audio',
      androidNotificationChannelName: 'Wavr Playback',
      androidNotificationOngoing:     true,
      androidStopForegroundOnPause:   true,
    );

    await svc.initNotifications();

    if (await FirstLaunch.isFirstLaunch()) {
      await SeedData.requestStoragePermission();
      await SeedData.seedTestTrack(db);

      final localFiles = await SeedData.scanLocalAudio();
      final dao        = TrackDao(db);
      for (final path in localFiles) {
        final name = p.basenameWithoutExtension(path);
        await dao.insert(Track(
          id:             const Uuid().v4(),
          title:          name,
          artist:         'Unknown',
          source:         TrackSource.local,
          localFilePath:  path,
          downloadStatus: DownloadStatus.done,
          addedAt:        DateTime.now(),
        ));
      }

      await FirstLaunch.markDone();
    }

    await svc.resumeQueue();
  } catch (_) {
    // Startup tasks are non-blocking; app should still show UI.
  }
}
