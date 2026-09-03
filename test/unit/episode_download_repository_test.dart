import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/episode_repository.dart';

void main() {
  group('EpisodeRepository - Download methods', () {
    late AppDatabase database;
    late EpisodeRepository repository;

    setUp(() {
      database = AppDatabase.forTest(NativeDatabase.memory());
      repository = EpisodeRepository(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('getEpisode returns episode by ID', () async {
      final db = database;
      final id = await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 1'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('guid-get-by-id'),
              publishDate: Value(DateTime.now()),
            ),
          );

      final episode = await repository.getEpisode(id);
      expect(episode != null, isTrue);
      expect(episode!.title, equals('Episode 1'));
    });

    test('getEpisode returns null for missing ID', () async {
      final episode = await repository.getEpisode(999);
      expect(episode == null, isTrue);
    });

    test('markAsDownloaded updates episode and creates download record',
        () async {
      final db = database;
      final id = await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 1'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('guid-mark-downloaded'),
              publishDate: Value(DateTime.now()),
            ),
          );

      await repository.markAsDownloaded(id, '/path/to/file.mp3', 1024);

      // Verify episode is updated
      final episode = await repository.getEpisode(id);
      expect(episode?.localPath, equals('/path/to/file.mp3'));

      // Verify download record is created
      final records = await (db.select(db.downloadRecords)
            ..where((t) => t.episodeId.equals(id)))
          .get();
      expect(records.length, equals(1));
      expect(records.first.fileSize, equals(1024));
      expect(records.first.status, equals(2)); // completed
    });

    test('clearDownloadInfo removes local path and download record', () async {
      final db = database;
      final id = await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Episode 1'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('guid-clear-download'),
              publishDate: Value(DateTime.now()),
            ),
          );

      // First mark as downloaded
      await repository.markAsDownloaded(id, '/path/to/file.mp3', 1024);

      // Then clear download info
      await repository.clearDownloadInfo(id);

      // Verify episode local path is cleared
      final episode = await repository.getEpisode(id);
      expect(episode?.localPath, null);

      // Verify download record is deleted
      final records = await (db.select(db.downloadRecords)
            ..where((t) => t.episodeId.equals(id)))
          .get();
      expect(records.isEmpty, isTrue);
    });

    test('getDownloadedEpisodes returns only downloaded episodes', () async {
      final db = database;
      // Insert episode with download
      await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Downloaded Episode'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep1.mp3'),
              guid: const Value('guid-downloaded'),
              localPath: const Value('/path/to/file.mp3'),
              publishDate: Value(DateTime.now()),
            ),
          );

      // Insert episode without download
      await db.into(db.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Not Downloaded Episode'),
              description: const Value('Description'),
              audioUrl: const Value('https://example.com/ep2.mp3'),
              guid: const Value('guid-not-downloaded'),
              publishDate: Value(DateTime.now()),
            ),
          );

      final downloaded = await repository.getDownloadedEpisodes().first;
      expect(downloaded.length, equals(1));
      expect(downloaded.first.title, equals('Downloaded Episode'));
    });
  });
}
