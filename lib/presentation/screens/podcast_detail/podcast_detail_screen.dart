import 'package:flutter/material.dart';

import '../../../data/datasources/local/app_database.dart';
import '../../../data/repositories/episode_repository.dart';
import '../../../data/repositories/podcast_repository.dart';
import '../../widgets/episode_list.dart';

class PodcastDetailScreen extends StatefulWidget {
  const PodcastDetailScreen({super.key, required this.podcastId});

  final int podcastId;

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  final PodcastRepository _repository = PodcastRepository();
  final EpisodeRepository _episodeRepository =
      EpisodeRepository(database: AppDatabase.instance);
  bool _isSubscribed = false;
  bool _isLoading = false;
  bool _isLoadingEpisodes = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    try {
      final subscription = await _repository.getSubscription(widget.podcastId);
      if (mounted) {
        setState(() {
          _isSubscribed = subscription != null;
        });
      }
    } on Exception {
      // Not subscribed yet
    }
  }

  Future<void> _toggleSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final wasSubscribed = _isSubscribed;
      if (wasSubscribed) {
        await _repository.unsubscribe(widget.podcastId);
      } else {
        await _repository.subscribeById(widget.podcastId);
      }

      setState(() {
        _isSubscribed = !wasSubscribed;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _refreshEpisodes() async {
    setState(() => _isLoadingEpisodes = true);
    try {
      final podcast = await _repository.getById(widget.podcastId);
      if (podcast != null && podcast.rssUrl.isNotEmpty) {
        await _episodeRepository.refreshEpisodes(widget.podcastId, podcast.rssUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingEpisodes = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSubscribed ? 'Podcast' : 'Podcast Detail'),
        actions: [
          if (_isSubscribed)
            Semantics(
              label: 'Refresh episodes',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isLoadingEpisodes ? null : _refreshEpisodes,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Podcast ID: ${widget.podcastId}'),
                const SizedBox(height: 16),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Semantics(
                    label: _isSubscribed ? 'Unsubscribe' : 'Subscribe',
                    button: true,
                    child: ElevatedButton(
                      onPressed: _toggleSubscription,
                      child:
                          Text(_isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                    ),
                  ),
              ],
            ),
          ),
          if (_isSubscribed) ...[
            const Divider(),
            Expanded(
              child: _isLoadingEpisodes
                  ? const Center(child: CircularProgressIndicator())
                  : EpisodeList(
                      podcastId: widget.podcastId,
                      episodeRepository: _episodeRepository,
                      onEpisodeTap: (episode) {
                        // TODO: Navigate to player
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Playing: ${episode.title}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
