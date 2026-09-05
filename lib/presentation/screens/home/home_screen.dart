import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/datasources/local/app_database.dart';
import '../../providers/podcast_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastsAsync = ref.watch(subscribedPodcastsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            onPressed: () => context.push('/downloads'),
            tooltip: 'Downloads',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: podcastsAsync.when(
        data: (podcasts) => _buildPodcastsList(context, ref, podcasts),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load subscriptions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastsList(BuildContext context, WidgetRef ref, List<Podcast> podcasts) {
    if (podcasts.isEmpty) {
      return const Center(
        child: Text('No subscriptions. Search for podcasts!'),
      );
    }

    return Semantics(
      label: 'Subscriptions list',
      child: ListView.builder(
        itemCount: podcasts.length,
        itemBuilder: (context, index) {
          final podcast = podcasts[index];
          return Semantics(
            label: '${podcast.title} by ${podcast.author}',
            button: true,
            child: ListTile(
              leading: podcast.artworkUrl.isNotEmpty
                  ? Image.network(
                      podcast.artworkUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.podcasts),
                    )
                  : const Icon(Icons.podcasts),
              title: Text(podcast.title),
              subtitle: Text(podcast.author),
              onTap: () => context.push('/podcast/${podcast.id}'),
            ),
          );
        },
      ),
    );
  }
}
