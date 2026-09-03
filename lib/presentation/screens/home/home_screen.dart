import 'package:flutter/material.dart';

import '../../../data/datasources/local/app_database.dart';
import '../../../data/repositories/podcast_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PodcastRepository _repository = PodcastRepository();
  List<Podcast> _subscribedPodcasts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final podcasts = await _repository.subscribedPodcasts.first;
      setState(() {
        _subscribedPodcasts = podcasts;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subscribedPodcasts.isEmpty
              ? const Center(
                  child: Text('No subscriptions. Search for podcasts!'),
                )
              : ListView.builder(
                  itemCount: _subscribedPodcasts.length,
                  itemBuilder: (context, index) {
                    final podcast = _subscribedPodcasts[index];
                    return ListTile(
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
                      onTap: () {
                        // Navigate to podcast detail
                      },
                    );
                  },
                ),
    );
  }
}
