import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_player/data/repositories/bookmark_repository.dart';
import 'package:podcast_player/data/repositories/episode_repository.dart';
import 'package:podcast_player/data/repositories/podcast_repository.dart';
import 'package:podcast_player/data/repositories/user_preference_repository.dart';
import 'database_provider.dart';

/// Provider for PodcastRepository with injected AppDatabase.
final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return PodcastRepository(database: database);
});

/// Provider for EpisodeRepository with injected AppDatabase.
final episodeRepositoryProvider = Provider<EpisodeRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return EpisodeRepository(database: database);
});

/// Provider for BookmarkRepository with injected AppDatabase.
final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return BookmarkRepository(database: database);
});

/// Provider for UserPreferenceRepository with injected AppDatabase.
final userPreferenceRepositoryProvider = Provider<UserPreferenceRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return UserPreferenceRepository(database: database);
});
