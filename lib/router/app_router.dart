import 'package:go_router/go_router.dart';

import '../presentation/screens/downloads/downloads_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/player/player_screen.dart';
import '../presentation/screens/podcast_detail/podcast_detail_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';

/// Application router configuration using go_router.
///
/// Defines all routes and their corresponding screens.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/podcast/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return PodcastDetailScreen(podcastId: id);
      },
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const PlayerScreen(),
    ),
    GoRoute(
      path: '/downloads',
      builder: (context, state) => const DownloadsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
