import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/app_database.dart';
import '../../../data/repositories/episode_repository.dart';
import '../../../presentation/providers/repository_providers.dart';
import '../../../presentation/providers/service_providers.dart';
import '../../../services/download_service.dart';
import '../../widgets/episode_tile.dart';

/// Provider for the DownloadsScreen state.
final downloadEpisodeProvider =
    StateNotifierProvider<DownloadController, DownloadState>((ref) {
  return DownloadController(
    episodeRepository: ref.watch(episodeRepositoryProvider),
    downloadService: ref.watch(downloadServiceProvider),
  );
});

/// Provider for downloaded episodes list.
final downloadedEpisodesProvider = StreamProvider<List<Episode>>((ref) {
  final repository = ref.watch(episodeRepositoryProvider);
  return repository.getDownloadedEpisodes();
});

/// Provider for storage usage.
final storageUsageProvider = Provider<Future<int>>((ref) {
  final service = ref.watch(downloadServiceProvider);
  return service.getTotalStorageUsed();
});

/// Download state for a single episode.
class DownloadState {
  final Map<int, double> progress;
  final Map<int, String> localPaths;

  DownloadState({
    this.progress = const {},
    this.localPaths = const {},
  });

  DownloadState copyWith({
    Map<int, double>? progress,
    Map<int, String>? localPaths,
  }) {
    return DownloadState(
      progress: progress ?? this.progress,
      localPaths: localPaths ?? this.localPaths,
    );
  }
}

/// Controller for managing downloads.
class DownloadController extends StateNotifier<DownloadState> {
  DownloadController({
    required this._episodeRepository,
    required this._downloadService,
  }) : super(DownloadState());

  final EpisodeRepository _episodeRepository;
  final DownloadService _downloadService;

  /// Download an episode.
  Future<void> downloadEpisode(Episode episode) async {
    try {
      final path = await _downloadService.download(
        url: episode.audioUrl,
        episodeId: episode.id,
        onProgress: (progress) {
          state = state.copyWith(
            progress: {...state.progress, episode.id: progress},
          );
        },
      );

      final fileSize = await _downloadService.getFileSize(path);
      await _episodeRepository.markAsDownloaded(episode.id, path, fileSize);

      state = state.copyWith(
        progress: {...state.progress}..remove(episode.id),
        localPaths: {...state.localPaths, episode.id: path},
      );
    } catch (e) {
      // Remove progress on error
      state = state.copyWith(
        progress: {...state.progress}..remove(episode.id),
      );
      rethrow;
    }
  }

  /// Delete a download.
  Future<void> deleteDownload(Episode episode) async {
    if (episode.localPath != null) {
      await _downloadService.deleteDownload(episode.localPath!);
      await _episodeRepository.clearDownloadInfo(episode.id);
      state = state.copyWith(
        localPaths: {...state.localPaths}..remove(episode.id),
      );
    }
  }

  /// Check if an episode is downloaded.
  bool isDownloaded(int episodeId) {
    return state.localPaths.containsKey(episodeId);
  }

  /// Check if a download is in progress.
  bool isDownloading(int episodeId) {
    return state.progress.containsKey(episodeId);
  }
}

/// Screen showing downloaded episodes and storage usage.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedEpisodesAsync = ref.watch(downloadedEpisodesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: downloadedEpisodesAsync.when(
        data: (episodes) => _buildDownloadsList(context, ref, episodes),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildDownloadsList(
    BuildContext context,
    WidgetRef ref,
    List<Episode> episodes,
  ) {
    if (episodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_for_offline_outlined, size: 64),
            SizedBox(height: 16),
            Text('No downloads yet'),
            SizedBox(height: 8),
            Text(
              'Download episodes to listen offline',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _StorageHeader(episodes: episodes),
        Expanded(
          child: Semantics(
            label: 'Downloaded episodes list',
            child: ListView.builder(
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return EpisodeTile(
                  title: episode.title,
                  duration: Duration(seconds: episode.duration ?? 0),
                  publishDate: episode.publishDate,
                  isPlayed: episode.isPlayed,
                  isFavorite: episode.isFavorite,
                  isNew: !episode.isPlayed,
                  localPath: episode.localPath,
                  onTap: () {},
                  onDeleteDownload: () async {
                    final controller = ref.read(downloadEpisodeProvider.notifier);
                    await controller.deleteDownload(episode);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StorageHeader extends StatelessWidget {
  const _StorageHeader({required this.episodes});

  final List<Episode> episodes;

  @override
  Widget build(BuildContext context) {
    final totalFiles = episodes.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.storage),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$totalFiles downloaded episodes',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
