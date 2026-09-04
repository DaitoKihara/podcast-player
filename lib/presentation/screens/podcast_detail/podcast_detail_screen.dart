import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/episode_repository.dart';
import '../../providers/podcast_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/player_provider.dart' hide episodeRepositoryProvider;
import '../../widgets/episode_list.dart';

class PodcastDetailScreen extends ConsumerWidget {
  const PodcastDetailScreen({super.key, required this.podcastId});

  final int podcastId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastAsync = ref.watch(podcastProvider(podcastId));
    final episodeRepository = ref.watch(episodeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: podcastAsync.when(
          data: (podcast) => Text(podcast?.title ?? 'Podcast Detail'),
          loading: () => const Text('Podcast Detail'),
          error: (_, __) => const Text('Podcast Detail'),
        ),
        actions: [
          if (podcastAsync.hasValue && podcastAsync.value != null)
            Semantics(
              label: 'Refresh episodes',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _refreshEpisodes(ref, episodeRepository),
              ),
            ),
        ],
      ),
      body: podcastAsync.when(
        data: (podcast) {
          if (podcast == null) {
            return const Center(child: Text('Podcast not found'));
          }
          return _buildPodcastDetail(context, ref, episodeRepository);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load podcast', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastDetail(
    BuildContext context,
    WidgetRef ref,
    EpisodeRepository episodeRepository,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Podcast ID: $podcastId'),
              const SizedBox(height: 16),
              Semantics(
                label: 'Subscribe',
                button: true,
                child: ElevatedButton(
                  onPressed: () => _toggleSubscription(ref),
                  child: const Text('Subscribe'),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: EpisodeList(
            podcastId: podcastId,
            episodeRepository: episodeRepository,
            onEpisodeTap: (episode) async {
              final audioService = ref.read(audioServiceProvider);
              await audioService.play(
                episode.audioUrl,
                startPosition: Duration(seconds: episode.playedPosition),
                title: episode.title,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Playing: ${episode.title}')),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _refreshEpisodes(
    WidgetRef ref,
    EpisodeRepository episodeRepository,
  ) async {
    try {
      final podcast = await ref.read(podcastProvider(podcastId).future);
      if (podcast != null && podcast.rssUrl.isNotEmpty) {
        await episodeRepository.refreshEpisodes(podcastId, podcast.rssUrl);
      }
    } catch (e) {
      // Error handled by provider
    }
  }

  Future<void> _toggleSubscription(WidgetRef ref) async {
    // TODO: Implement subscription toggle via Riverpod notifier
  }
}
