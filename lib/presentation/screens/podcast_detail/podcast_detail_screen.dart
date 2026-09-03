import 'package:flutter/material.dart';

import '../../../data/repositories/podcast_repository.dart';

class PodcastDetailScreen extends StatefulWidget {
  const PodcastDetailScreen({super.key, required this.podcastId});

  final int podcastId;

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  final PodcastRepository _repository = PodcastRepository();
  bool _isSubscribed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    // TODO: Check if already subscribed
  }

  Future<void> _toggleSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Toggle subscription
      setState(() {
        _isSubscribed = !_isSubscribed;
        _isLoading = false;
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcast Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Podcast ID: ${widget.podcastId}'),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _toggleSubscription,
                    child: Text(_isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                  ),
          ],
        ),
      ),
    );
  }
}
