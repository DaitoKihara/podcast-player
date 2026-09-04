import '../../data/repositories/episode_repository.dart';

class GetNewEpisodes {
  GetNewEpisodes({
    required EpisodeRepository episodeRepository,
  }) : _episodeRepository = episodeRepository;

  final EpisodeRepository _episodeRepository;

  Future<List<Episode>> call(int podcastId) async {
    return _episodeRepository.getNewEpisodes(podcastId).first;
  }
}
