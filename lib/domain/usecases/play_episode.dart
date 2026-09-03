import '../../data/repositories/episode_repository.dart';
import '../../services/audio_service.dart';

/// Use case for playing an episode.
class PlayEpisode {
  PlayEpisode({
    EpisodeRepository? episodeRepository,
    AudioService? audioService,
  })  : _episodeRepository = episodeRepository ?? EpisodeRepository(),
        _audioService = audioService ?? AudioService();

  final EpisodeRepository _episodeRepository;
  final AudioService _audioService;

  /// Plays an episode, starting from the last known position if available.
  Future<void> call(int episodeId) async {
    final episode = await _episodeRepository.getEpisodes(episodeId).then(
          (episodes) => episodes.isEmpty ? null : episodes.first,
        );

    if (episode == null) {
      throw Exception('Episode not found');
    }

    await _audioService.play(
      episode.audioUrl,
      startPosition: Duration(seconds: episode.playedPosition),
      title: episode.title,
    );
  }
}
