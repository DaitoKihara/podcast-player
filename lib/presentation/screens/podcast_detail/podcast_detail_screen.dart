import 'package:flutter/material.dart';

class PodcastDetailScreen extends StatelessWidget {
  const PodcastDetailScreen({super.key, required this.podcastId});

  final int podcastId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcast Detail')),
      body: const Center(child: Text('Podcast Detail Screen')),
    );
  }
}
