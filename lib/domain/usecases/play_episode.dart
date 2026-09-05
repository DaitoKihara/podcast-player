import '../../data/repositories/episode_repository.dart';
import '../../services/audio_service.dart';

class PlayEpisode {
  PlayEpisode({
    required EpisodeRepository episodeRepository,
    AudioService? audioService,
  })  : _episodeRepository = episodeRepository,
        _audioService = audioService ?? AudioService();

  final EpisodeRepository _episodeRepository;
  final AudioService _audioService;

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
