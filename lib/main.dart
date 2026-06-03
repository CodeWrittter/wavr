import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
// import 'package:metadata_god/metadata_god.dart';
import 'app.dart';
import 'data/database/app_database.dart';
import 'services/download/download_service.dart';
import 'services/download/download_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init metadata_god (required before any tag read/write)
  // MetadataGod.initialize();

  // MUST be before runApp
  await JustAudioBackground.init(
    androidNotificationChannelId:   'com.wavr.app.channel.audio',
    androidNotificationChannelName: 'Wavr Playback',
    androidNotificationOngoing:     true,
    androidStopForegroundOnPause:   true,
  );

  final db    = AppDatabase();
  final queue = DownloadQueue(db: db);
  final svc   = DownloadService(db: db, queue: queue);

  await svc.initNotifications();
  await svc.resumeQueue();

  runApp(
    ProviderScope(
      child: WavrApp(db: db),
    ),
  );
}
