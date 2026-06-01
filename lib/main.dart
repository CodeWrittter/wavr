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
