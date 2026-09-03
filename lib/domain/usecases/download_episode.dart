import 'dart:io';

import '../../data/repositories/episode_repository.dart';
import '../../data/repositories/user_preference_repository.dart';
import '../../services/download_service.dart';
import '../../domain/entities/app_exception.dart';

/// Use case for downloading an episode for offline playback.
///
/// Validates Wi-Fi setting and storage capacity before downloading.
class DownloadEpisode {
  DownloadEpisode({
    EpisodeRepository? episodeRepository,
    DownloadService? downloadService,
    UserPreferenceRepository? userPreferenceRepository,
  })  : _episodeRepository = episodeRepository ?? EpisodeRepository(),
        _downloadService = downloadService ?? DownloadService(),
        _userPreferenceRepository =
            userPreferenceRepository ?? UserPreferenceRepository();

  final EpisodeRepository _episodeRepository;
  final DownloadService _downloadService;
  final UserPreferenceRepository _userPreferenceRepository;

  /// Download an episode for offline playback.
  ///
  /// [episodeId] The episode ID to download.
  /// [onProgress] Optional progress callback (0.0 to 1.0).
  ///
  /// Returns the local file path of the downloaded episode.
  ///
  /// Throws [DownloadException] if the download fails.
  /// Throws [WifiRequiredException] if Wi-Fi is required but not connected.
  Future<String> call({
    required int episodeId,
    void Function(double progress)? onProgress,
  }) async {
    // Get the episode by ID
    final episode = await _episodeRepository.getEpisode(episodeId);
    if (episode == null) {
      throw AppException.storage(message: 'Episode not found');
    }

    // Check if already downloaded
    if (episode.localPath != null) {
      final file = File(episode.localPath!);
      if (await file.exists()) {
        return episode.localPath!;
      }
    }

    // Check Wi-Fi only setting
    final wifiOnly = await _userPreferenceRepository.isWifiOnlyDownloadEnabled();
    if (wifiOnly) {
      final isWifi = await _downloadService.isWifiConnected();
      if (!isWifi) {
        throw WifiRequiredException();
      }
    }

    // Download the file
    final localPath = await _downloadService.download(
      url: episode.audioUrl,
      episodeId: episodeId,
      onProgress: onProgress,
    );

    // Get file size
    final fileSize = await _downloadService.getFileSize(localPath);

    // Update episode record with download info
    await _episodeRepository.markAsDownloaded(episodeId, localPath, fileSize);

    return localPath;
  }

  /// Cancel a download.
  void cancel(int episodeId) {
    _downloadService.cancelDownload(episodeId);
  }

  /// Delete a downloaded episode.
  Future<void> deleteDownload(int episodeId) async {
    final episodes = await _episodeRepository.getEpisodes(episodeId);
    if (episodes.isEmpty) return;

    final episode = episodes.first;
    if (episode.localPath != null) {
      await _downloadService.deleteDownload(episode.localPath!);
      await _episodeRepository.clearDownloadInfo(episodeId);
    }
  }
}

/// Exception thrown when Wi-Fi is required but not connected.
class WifiRequiredException implements Exception {
  @override
  String toString() =>
      'WifiRequiredException: Wi-Fi connection required for download';
}
