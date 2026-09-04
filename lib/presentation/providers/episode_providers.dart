import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/episode_repository.dart';
import 'package:podcast_player/presentation/providers/repository_providers.dart';

/// State for episodes of a podcast.
class EpisodesState {
  const EpisodesState({
    this.episodes = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Episode> episodes;
  final bool isLoading;
  final String? error;

  EpisodesState copyWith({
    List<Episode>? episodes,
    bool? isLoading,
    String? error,
  }) {
    return EpisodesState(
      episodes: episodes ?? this.episodes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for managing episodes state.
class EpisodesNotifier extends StateNotifier<EpisodesState> {
  EpisodesNotifier(this._episodeRepository, this._podcastId)
      : super(const EpisodesState());

  final EpisodeRepository _episodeRepository;
  final int _podcastId;

  /// Load episodes for the podcast.
  Future<void> loadEpisodes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final episodes = await _episodeRepository.getEpisodes(_podcastId);
      state = state.copyWith(
        episodes: episodes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh episodes from RSS feed.
  Future<void> refreshEpisodes(String rssUrl) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _episodeRepository.refreshEpisodes(_podcastId, rssUrl);
      await loadEpisodes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Provider for episodes state management.
///
/// Takes a podcast ID as parameter.
final episodesProvider =
    StateNotifierProvider.family<EpisodesNotifier, EpisodesState, int>(
  (ref, podcastId) {
    final repository = ref.watch(episodeRepositoryProvider);
    return EpisodesNotifier(repository, podcastId);
  },
);
