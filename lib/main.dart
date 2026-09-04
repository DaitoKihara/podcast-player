import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'router/app_router.dart';
import 'presentation/providers/player_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.daitokihara.podcast.channel.audio',
      androidNotificationChannelName: 'Podcast Playback',
      androidNotificationOngoing: true,
    );

    // Drift database is auto-initialized on first access
  } on Exception catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: PodcastPlayerApp(),
    ),
  );
}

class PodcastPlayerApp extends ConsumerWidget {
  const PodcastPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load user preferences for theme and font size
    final prefsAsync = ref.watch(userPreferenceProvider);

    return prefsAsync.when(
      data: (prefs) => MaterialApp.router(
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
        themeMode: prefs?.darkMode == true ? ThemeMode.dark : ThemeMode.light,
        routerConfig: appRouter,
      ),
      loading: () => MaterialApp.router(
        title: 'Podcast Player',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
      error: (_, __) => MaterialApp.router(
        title: 'Podcast Player',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
