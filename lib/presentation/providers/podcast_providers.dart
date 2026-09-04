import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/podcast_repository.dart';
import 'package:podcast_player/presentation/providers/repository_providers.dart';
import 'package:podcast_player/domain/entities/podcast_search_query.dart';

/// Provider for subscribed podcasts stream.
///
/// Returns a stream of subscribed podcasts from the database,
/// ordered by subscription date (newest first).
final subscribedPodcastsProvider = StreamProvider<List<Podcast>>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return repository.subscribedPodcasts;
});

/// Provider for a single podcast by ID.
///
/// Returns null if the podcast is not found.
final podcastProvider = FutureProvider.family<Podcast?, int>((ref, id) {
  final repository = ref.watch(podcastRepositoryProvider);
  return repository.getById(id);
});

/// State for search screen.
class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  final String query;
  final List<Podcast> results;
  final bool isLoading;
  final String? error;

  SearchState copyWith({
    String? query,
    List<Podcast>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for search state management.
class SearchPodcastsNotifier extends StateNotifier<SearchState> {
  SearchPodcastsNotifier(this._repository) : super(const SearchState());

  final PodcastRepository _repository;

  /// Search for podcasts by keyword.
  Future<void> search(String term) async {
    if (term.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: term);

    try {
      final query = PodcastSearchQuery(
        term: term,
        limit: 50,
        offset: 0,
      );
      final results = await _repository.search(query);
      state = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear search results.
  void clear() {
    state = const SearchState();
  }
}

/// Provider for search state management.
final searchPodcastsProvider =
    StateNotifierProvider<SearchPodcastsNotifier, SearchState>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return SearchPodcastsNotifier(repository);
});
