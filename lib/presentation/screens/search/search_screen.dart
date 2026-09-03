import 'package:flutter/material.dart';

import '../../../data/datasources/local/app_database.dart';
import '../../../data/repositories/podcast_repository.dart';
import '../../../domain/entities/podcast_search_query.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  _SearchScreenState();

  final PodcastRepository _repository = PodcastRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Podcast> _results = [];
  bool _isLoading = false;

  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final query = PodcastSearchQuery(
        term: _searchController.text,
        limit: 50,
        offset: 0,
      );
      final results = await _repository.search(query);
      setState(() {
        _results = results;
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search podcasts...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(
                        child: Text('No results. Try searching!'),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final podcast = _results[index];
                          return ListTile(
                            leading: podcast.artworkUrl.isNotEmpty
                                ? Image.network(
                                    podcast.artworkUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.podcasts),
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
          ),
        ],
      ),
    );
  }
}
