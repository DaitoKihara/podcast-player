import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/episode_repository.dart';

void main() {
  group('EpisodeRepository', () {
    late AppDatabase database;
    late EpisodeRepository repository;

    setUp(() {
      database = AppDatabase.forTest(NativeDatabase.memory());
      repository = EpisodeRepository(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('getEpisodes returns empty list for new database', () async {
      final episodes = await repository.getEpisodes(1);
      expect(episodes, isEmpty);
    });

    test('getEpisodes returns episodes for podcast', () async {
      final db = database;
      await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 1'),
              description: const Value('First episode'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('guid-1'),
              publishDate: Value(DateTime.now()),
            ),
          );
      await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 2'),
              description: const Value('Second episode'),
              audioUrl: const Value('https://example.com/ep2.mp3'),
              guid: const Value('guid-2'),
              publishDate: Value(DateTime.now().subtract(const Duration(days: 1))),
            ),
          );

      final episodes = await repository.getEpisodes(1);
      expect(episodes.length, equals(2));
      // Should be ordered by publishDate desc
      expect(episodes.first.title, equals('Episode 1'));
    });

    test('getNewEpisodes returns only unplayed episodes', () async {
      final db = database;
      await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('New Episode'),
              description: const Value('New episode description'),
              audioUrl: const Value('https://example.com/new.mp3'),
              guid: const Value('guid-new'),
              isPlayed: const Value(false),
              publishDate: Value(DateTime.now()),
            ),
          );
      await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Played Episode'),
              description: const Value('Played episode description'),
              audioUrl: const Value('https://example.com/played.mp3'),
              guid: const Value('guid-played'),
              isPlayed: const Value(true),
              publishDate: Value(DateTime.now().subtract(const Duration(days: 1))),
            ),
          );

      final newEpisodes = await repository.getNewEpisodes(1).first;
      expect(newEpisodes.length, equals(1));
      expect(newEpisodes.first.title, equals('New Episode'));
    });

    test('markAsPlayed updates episode', () async {
      final db = database;
      final id = await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 1'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('guid-1'),
              publishDate: Value(DateTime.now()),
            ),
          );

      await repository.markAsPlayed(id, 120);

      final episodes = await repository.getEpisodes(1);
      expect(episodes.first.isPlayed, isTrue);
      expect(episodes.first.playedPosition, equals(120));
    });

    test('toggleFavorite flips favorite status', () async {
      final db = database;
      final id = await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 1'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('guid-1'),
              publishDate: Value(DateTime.now()),
            ),
          );

      expect((await repository.getEpisodes(1)).first.isFavorite, isFalse);

      await repository.toggleFavorite(id);
      expect((await repository.getEpisodes(1)).first.isFavorite, isTrue);

      await repository.toggleFavorite(id);
      expect((await repository.getEpisodes(1)).first.isFavorite, isFalse);
    });

    test('updatePosition updates position', () async {
      final db = database;
      final id = await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 1'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('guid-1'),
              publishDate: Value(DateTime.now()),
            ),
          );

      await repository.updatePosition(id, 300);

      final episodes = await repository.getEpisodes(1);
      expect(episodes.first.playedPosition, equals(300));
    });

    test('getByGuid returns correct episode', () async {
      final db = database;
      await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 1'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('unique-guid'),
              publishDate: Value(DateTime.now()),
            ),
          );

      final episode = await repository.getByGuid('unique-guid');
      expect(episode != null, isTrue);
      expect(episode!.title, equals('Episode 1'));
    });

    test('getByGuid returns null for missing guid', () async {
      final episode = await repository.getByGuid('nonexistent');
      expect(episode == null, isTrue);
    });
  });
}
