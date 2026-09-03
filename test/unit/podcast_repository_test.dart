import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/repositories/podcast_repository.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/domain/entities/podcast_search_query.dart';

void main() {
  group('PodcastRepository', () {
    late PodcastRepository repository;

    setUp(() {
      repository = PodcastRepository();
    });

    test('search returns list of podcasts', () async {
      final results = await repository.search(
        PodcastSearchQuery(term: 'tech', limit: 10, offset: 0),
      );

      expect(results, isA<List>());
      if (results.isNotEmpty) {
        final first = results.first;
        expect(first.title, isA<String>());
        expect(first.author, isA<String>());
      }
    });

    test('subscribe adds podcast to database', () async {
      final podcast = Podcast(
        id: 0,
        itunesId: 123456,
        title: 'Test Podcast',
        author: 'Test Author',
        description: 'Test Description',
        artworkUrl: 'https://example.com/artwork.jpg',
        rssUrl: 'https://example.com/feed.xml',
        category: 'Technology',
        episodeCount: 100,
        subscribedAt: DateTime.now(),
        autoDownload: false,
        notificationsEnabled: true,
      );

      await repository.subscribe(podcast);

      final saved = await repository.getById(podcast.id);
      expect(saved, isNotNull);
      expect(saved!.title, equals('Test Podcast'));
    });

    test('unsubscribe removes podcast from database', () async {
      final podcast = Podcast(
        id: 0,
        itunesId: 123457,
        title: 'Test Podcast 2',
        author: 'Test Author 2',
        description: 'Test Description 2',
        artworkUrl: 'https://example.com/artwork2.jpg',
        rssUrl: 'https://example.com/feed2.xml',
        category: 'Technology',
        episodeCount: 50,
        subscribedAt: DateTime.now(),
        autoDownload: false,
        notificationsEnabled: true,
      );

      await repository.subscribe(podcast);
      await repository.unsubscribe(podcast.id);

      final saved = await repository.getById(podcast.id);
      expect(saved, isNull);
    });
  });
}
