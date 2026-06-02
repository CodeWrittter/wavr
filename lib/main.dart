import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // init metadata_god (required before any tag read/write)
  // MetadataGod.initialize();

  // single db instance for the whole startup sequence
  final db    = AppDatabase();
  final queue = DownloadQueue(db: db);
  final svc   = DownloadService(db: db, queue: queue);

  // init notifications
  await svc.initNotifications();

  // first launch setup
  if (await FirstLaunch.isFirstLaunch()) {
    await SeedData.requestStoragePermission();
    await SeedData.seedTestTrack(db);

    // scan and insert local audio files
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

  // resume any pending downloads from previous session
  await svc.resumeQueue();

  runApp(
    const ProviderScope(
      child: WavrApp(),
    ),
  );
}
