import '../../data/repositories/episode_repository.dart';

class MarkAsPlayed {
  MarkAsPlayed({
    required EpisodeRepository episodeRepository,
  }) : _episodeRepository = episodeRepository;

  final EpisodeRepository _episodeRepository;

  Future<bool> call({
    required int episodeId,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    final threshold = durationSeconds * 0.9;
    final shouldMarkPlayed = positionSeconds >= threshold;

    if (shouldMarkPlayed) {
      await _episodeRepository.markAsPlayed(episodeId, positionSeconds);
    } else {
      await _episodeRepository.updatePosition(episodeId, positionSeconds);
    }

    return shouldMarkPlayed;
  }

  static bool isThresholdMet({
    required int positionSeconds,
    required int durationSeconds,
  }) {
    if (durationSeconds <= 0) return false;
    return positionSeconds >= durationSeconds * 0.9;
  }
}
