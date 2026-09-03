import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/podcast_repository.dart';
import 'package:podcast_player/domain/entities/podcast_search_query.dart';

void main() {
  late AppDatabase database;
  late PodcastRepository repository;

  setUp(() {
    database = AppDatabase.forTest(InMemoryDatabase());
    repository = PodcastRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('search returns empty list for empty query', () async {
    final results = await repository.search(
      const PodcastSearchQuery(term: '', limit: 10, offset: 0),
    );
    expect(results, isEmpty);
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
}
