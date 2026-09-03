import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'data/datasources/local/isar_database.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Just Audio Background
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.daitokihara.podcast.channel.audio',
    androidNotificationChannelName: 'Podcast Playback',
    androidNotificationOngoing: true,
  );

  // Initialize Isar Database
  await IsarDatabase.instance.initialize();

  runApp(
    const ProviderScope(
      child: PodcastPlayerApp(),
    ),
  );
}

class PodcastPlayerApp extends StatelessWidget {
  const PodcastPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Podcast Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
