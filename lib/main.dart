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

  debugPrint("WAVR STEP 1");

  // init metadata_god (required before any tag read/write)
  // MetadataGod.initialize();

  // MUST be before runApp
  // await JustAudioBackground.init(
  //   androidNotificationChannelId:   'com.wavr.app.channel.audio',
  //   androidNotificationChannelName: 'Wavr Playback',
  //   androidNotificationOngoing:     true,
  //   androidStopForegroundOnPause:   true,
  // );

  debugPrint("WAVR STEP 2");

  final db    = AppDatabase();
  debugPrint("WAVR STEP 3");

  final queue = DownloadQueue(db: db);
  final svc   = DownloadService(db: db, queue: queue);
  debugPrint("WAVR STEP 4");

  await svc.initNotifications();
  debugPrint("WAVR STEP 5");
  await svc.resumeQueue();
  debugPrint("WAVR STEP 6");

  runApp(
    ProviderScope(
      child: WavrApp(db: db),
    ),
  );
  debugPrint("WAVR STEP 7");

}
