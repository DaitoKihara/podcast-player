import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/podcast_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchPodcastsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Search podcasts',
                    textField: true,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search podcasts...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (term) {
                        ref.read(searchPodcastsProvider.notifier).search(term);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: 'Search',
                  button: true,
                  child: ElevatedButton(
                    onPressed: () {
                      final term = _searchController.text.trim();
                      if (term.isNotEmpty) {
                        ref.read(searchPodcastsProvider.notifier).search(term);
                      }
                    },
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildSearchResults(context, searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Search failed', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(state.error!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return const Center(child: Text('No results. Try searching!'));
    }

    return Semantics(
      label: 'Search results',
      child: ListView.builder(
        itemCount: state.results.length,
        itemBuilder: (context, index) {
          final podcast = state.results[index];
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
