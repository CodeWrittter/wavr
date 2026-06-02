import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:metadata_god/metadata_god.dart';
import 'app.dart';
import 'services/download/download_service.dart';
import 'data/database/app_database.dart';
import 'services/download/download_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init metadata_god (required before any tag read/write)
  // MetadataGod.initialize();

  if (await FirstLaunch.isFirstLaunch()) {
    await SeedData.requestStoragePermission();
    await SeedData.seedTestTrack(db);
    // scan and insert local files
    final localFiles = await SeedData.scanLocalAudio();
    final dao = TrackDao(db);
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

  final db = AppDatabase();
  if (await FirstLaunch.isFirstLaunch()) {
    await SeedData.seedTestTrack(db);
    await FirstLaunch.markDone();
  }

  // init local notifications channel
  final db    = AppDatabase();
  final queue = DownloadQueue(db: db);
  final svc   = DownloadService(db: db, queue: queue);
  await svc.initNotifications();

  // resume any pending downloads from previous session
  await svc.resumeQueue();

  runApp(
    const ProviderScope(
      child: WavrApp(),
    ),
  );
}
