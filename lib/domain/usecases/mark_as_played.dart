import '../../data/repositories/episode_repository.dart';

/// Use case for marking an episode as played with 90% threshold logic.
///
/// If the playback position reaches 90% or more of the total duration,
/// the episode is automatically marked as played.
class MarkAsPlayed {
  MarkAsPlayed({
    EpisodeRepository? episodeRepository,
  }) : _episodeRepository = episodeRepository ?? EpisodeRepository();

  final EpisodeRepository _episodeRepository;

  /// Updates playback position and marks as played if >= 90% threshold.
  ///
  /// [episodeId] The episode ID.
  /// [positionSeconds] Current playback position in seconds.
  /// [durationSeconds] Total duration in seconds.
  ///
  /// Returns true if the episode was marked as played, false otherwise.
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

  /// Checks if the given position/duration ratio meets the 90% threshold.
  static bool isThresholdMet({
    required int positionSeconds,
    required int durationSeconds,
  }) {
    if (durationSeconds <= 0) return false;
    return positionSeconds >= durationSeconds * 0.9;
  }
}
