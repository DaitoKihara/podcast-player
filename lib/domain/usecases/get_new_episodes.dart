import '../../data/datasources/local/app_database.dart';
import '../../data/repositories/episode_repository.dart';

/// Use case for getting new (unplayed) episodes for a podcast.
class GetNewEpisodes {
  GetNewEpisodes({
    EpisodeRepository? episodeRepository,
  }) : _episodeRepository = episodeRepository ?? EpisodeRepository(database: AppDatabase.instance);

  final EpisodeRepository _episodeRepository;

  /// Returns a list of unplayed episodes for the given podcast.
  Future<List<Episode>> call(int podcastId) async {
    return _episodeRepository.getNewEpisodes(podcastId).first;
  }
}
