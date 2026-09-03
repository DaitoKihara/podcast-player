import 'package:flutter/material.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/repositories/episode_repository.dart';
import 'episode_tile.dart';

/// Filter options for episode list.
enum EpisodeFilter { all, unread, favorites }

/// Sort options for episode list.
enum EpisodeSort { newestFirst, oldestFirst }

/// A widget that displays a list of episodes with filter and sort controls.
class EpisodeList extends StatefulWidget {
  const EpisodeList({
    super.key,
    required this.podcastId,
    required this.episodeRepository,
    this.onEpisodeTap,
  });

  final int podcastId;
  final EpisodeRepository episodeRepository;
  final void Function(Episode episode)? onEpisodeTap;

  @override
  State<EpisodeList> createState() => _EpisodeListState();
}

class _EpisodeListState extends State<EpisodeList> {
  EpisodeFilter _filter = EpisodeFilter.all;
  EpisodeSort _sort = EpisodeSort.newestFirst;
  List<Episode> _allEpisodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    setState(() => _isLoading = true);
    try {
      final episodes = await widget.episodeRepository.getEpisodes(
        widget.podcastId,
      );
      setState(() {
        _allEpisodes = episodes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Episode> get _filteredEpisodes {
    var episodes = _allEpisodes;

    // Apply filter
    switch (_filter) {
      case EpisodeFilter.all:
        break;
      case EpisodeFilter.unread:
        episodes = episodes.where((e) => !e.isPlayed).toList();
      case EpisodeFilter.favorites:
        episodes = episodes.where((e) => e.isFavorite).toList();
    }

    // Apply sort
    switch (_sort) {
      case EpisodeSort.newestFirst:
        episodes = List.of(episodes)
          ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
      case EpisodeSort.oldestFirst:
        episodes = List.of(episodes)
          ..sort((a, b) => a.publishDate.compareTo(b.publishDate));
    }

    return episodes;
  }

  Future<void> _toggleFavorite(Episode episode) async {
    try {
      await widget.episodeRepository.toggleFavorite(episode.id);
      await _loadEpisodes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _markAsPlayed(Episode episode) async {
    try {
      await widget.episodeRepository.markAsPlayed(
        episode.id,
        episode.duration ?? 0,
      );
      await _loadEpisodes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _markAsUnplayed(Episode episode) async {
    try {
      await widget.episodeRepository.updatePosition(episode.id, 0);
      // Also need to set isPlayed to false
      await widget.episodeRepository.markAsUnplayed(episode.id);
      await _loadEpisodes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEpisodes = _filteredEpisodes;

    return Column(
      children: [
        _buildFilterChips(),
        _buildSortOptions(),
        const Divider(height: 1),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredEpisodes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: filteredEpisodes.length,
                      itemBuilder: (context, index) {
                        final episode = filteredEpisodes[index];
                        return EpisodeTile(
                          title: episode.title,
                          duration: Duration(seconds: episode.duration ?? 0),
                          publishDate: episode.publishDate,
                          isPlayed: episode.isPlayed,
                          isFavorite: episode.isFavorite,
                          isNew: !episode.isPlayed &&
                              DateTime.now()
                                      .difference(episode.publishDate)
                                      .inDays <
                                  7,
                          onTap: () => widget.onEpisodeTap?.call(episode),
                          onFavoriteToggle: () => _toggleFavorite(episode),
                          onMarkPlayed: () => _markAsPlayed(episode),
                          onMarkUnplayed: () => _markAsUnplayed(episode),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _filter == EpisodeFilter.all,
            onSelected: (_) => setState(() => _filter = EpisodeFilter.all),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Unread'),
            selected: _filter == EpisodeFilter.unread,
            onSelected: (_) =>
                setState(() => _filter = EpisodeFilter.unread),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Favorites'),
            selected: _filter == EpisodeFilter.favorites,
            onSelected: (_) =>
                setState(() => _filter = EpisodeFilter.favorites),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Sort: '),
          TextButton(
            onPressed: () => setState(() => _sort = EpisodeSort.newestFirst),
            child: Text(
              'Newest',
              style: TextStyle(
                fontWeight: _sort == EpisodeSort.newestFirst
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _sort = EpisodeSort.oldestFirst),
            child: Text(
              'Oldest',
              style: TextStyle(
                fontWeight: _sort == EpisodeSort.oldestFirst
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_filter) {
      case EpisodeFilter.all:
        message = 'No episodes found';
      case EpisodeFilter.unread:
        message = 'No unread episodes';
      case EpisodeFilter.favorites:
        message = 'No favorite episodes';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
