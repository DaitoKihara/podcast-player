import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/episode_repository.dart';

void main() {
  group('ToggleFavorite', () {
    late AppDatabase database;
    late EpisodeRepository repository;

    setUp(() {
      database = AppDatabase.forTest(NativeDatabase.memory());
      repository = EpisodeRepository(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('toggleFavorite flips isFavorite from false to true', () async {
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
    });

    test('toggleFavorite flips isFavorite from true to false', () async {
      final db = database;
      final id = await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 1'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('guid-1'),
              isFavorite: const Value(true),
              publishDate: Value(DateTime.now()),
            ),
          );

      expect((await repository.getEpisodes(1)).first.isFavorite, isTrue);

      await repository.toggleFavorite(id);

      expect((await repository.getEpisodes(1)).first.isFavorite, isFalse);
    });

    test('toggleFavorite throws when episode not found', () async {
      expect(
        () => repository.toggleFavorite(999),
        throwsA(isA<Exception>()),
      );
    });
  });
}
