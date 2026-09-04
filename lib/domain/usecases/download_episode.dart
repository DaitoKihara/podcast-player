import 'dart:io';

import '../../data/repositories/episode_repository.dart';
import '../../data/repositories/user_preference_repository.dart';
import '../../services/download_service.dart';
import '../../domain/entities/app_exception.dart';

class DownloadEpisode {
  DownloadEpisode({
    required EpisodeRepository episodeRepository,
    DownloadService? downloadService,
    required UserPreferenceRepository userPreferenceRepository,
  })  : _episodeRepository = episodeRepository,
        _downloadService = downloadService ?? DownloadService(),
        _userPreferenceRepository = userPreferenceRepository;

  final EpisodeRepository _episodeRepository;
  final DownloadService _downloadService;
  final UserPreferenceRepository _userPreferenceRepository;

  Future<String> call({
    required int episodeId,
    void Function(double progress)? onProgress,
  }) async {
    final episode = await _episodeRepository.getEpisode(episodeId);
    if (episode == null) {
      throw AppException.storage(message: 'Episode not found');
    }

    if (episode.localPath != null) {
      final file = File(episode.localPath!);
      if (await file.exists()) {
        return episode.localPath!;
      }
    }

    final wifiOnly = await _userPreferenceRepository.isWifiOnlyDownloadEnabled();
    if (wifiOnly) {
      final isWifi = await _downloadService.isWifiConnected();
      if (!isWifi) {
        throw WifiRequiredException();
      }
    }

    final localPath = await _downloadService.download(
      url: episode.audioUrl,
      episodeId: episodeId,
      onProgress: onProgress,
    );

    final fileSize = await _downloadService.getFileSize(localPath);
    await _episodeRepository.markAsDownloaded(episodeId, localPath, fileSize);

    return localPath;
  }

  void cancel(int episodeId) {
    _downloadService.cancelDownload(episodeId);
  }

  Future<void> deleteDownload(int episodeId) async {
    final episode = await _episodeRepository.getEpisode(episodeId);
    if (episode == null) return;

    if (episode.localPath != null) {
      await _downloadService.deleteDownload(episode.localPath!);
      await _episodeRepository.clearDownloadInfo(episodeId);
    }
  }
}

class WifiRequiredException implements Exception {
  @override
  String toString() =>
      'WifiRequiredException: Wi-Fi connection required for download';
}
