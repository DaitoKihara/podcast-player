import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNull, isNotNull;
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/bookmark_repository.dart';
import 'package:podcast_player/domain/entities/app_exception.dart';

void main() {
  group('BookmarkRepository', () {
    late AppDatabase database;
    late BookmarkRepository repository;

    setUp(() {
      database = AppDatabase.forTest(NativeDatabase.memory());
      repository = BookmarkRepository(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('getBookmarksForEpisode returns empty list for new database', () async {
      final bookmarks = await repository.getBookmarksForEpisode(1);
      expect(bookmarks, isEmpty);
    });

    test('addBookmark adds a bookmark', () async {
      final id = await repository.addBookmark(
        episodeId: 1,
        position: 300,
        note: 'Interesting part',
      );

      expect(id, greaterThan(0));

      final bookmarks = await repository.getBookmarksForEpisode(1);
      expect(bookmarks.length, equals(1));
      expect(bookmarks.first.position, equals(300));
      expect(bookmarks.first.note, equals('Interesting part'));
    });

    test('addBookmark without note', () async {
      await repository.addBookmark(episodeId: 1, position: 600);

      final bookmarks = await repository.getBookmarksForEpisode(1);
      expect(bookmarks.length, equals(1));
      expect(bookmarks.first.note, equals(null));
    });

    test('addBookmark throws on duplicate position', () async {
      await repository.addBookmark(episodeId: 1, position: 300);

      expect(
        () => repository.addBookmark(episodeId: 1, position: 300),
        throwsA(isA<AppException>()),
      );
    });

    test('getBookmarksForEpisode returns bookmarks ordered by position', () async {
      await repository.addBookmark(episodeId: 1, position: 600);
      await repository.addBookmark(episodeId: 1, position: 300);
      await repository.addBookmark(episodeId: 1, position: 900);

      final bookmarks = await repository.getBookmarksForEpisode(1);
      expect(bookmarks.length, equals(3));
      expect(bookmarks[0].position, equals(300));
      expect(bookmarks[1].position, equals(600));
      expect(bookmarks[2].position, equals(900));
    });

    test('getBookmarksForEpisode filters by episode', () async {
      await repository.addBookmark(episodeId: 1, position: 300);
      await repository.addBookmark(episodeId: 2, position: 300);

      final bookmarks1 = await repository.getBookmarksForEpisode(1);
      final bookmarks2 = await repository.getBookmarksForEpisode(2);

      expect(bookmarks1.length, equals(1));
      expect(bookmarks2.length, equals(1));
      expect(bookmarks1.first.episodeId, equals(1));
      expect(bookmarks2.first.episodeId, equals(2));
    });

    test('getBookmark returns correct bookmark', () async {
      final id = await repository.addBookmark(
        episodeId: 1,
        position: 300,
        note: 'Test note',
      );

      final bookmark = await repository.getBookmark(id);
      expect(bookmark, isNot(equals(null)));
      expect(bookmark!.id, equals(id));
      expect(bookmark.position, equals(300));
      expect(bookmark.note, equals('Test note'));
    });

    test('getBookmark returns null for missing id', () async {
      final bookmark = await repository.getBookmark(999);
      expect(bookmark, equals(null));
    });

    test('deleteBookmark removes the bookmark', () async {
      final id = await repository.addBookmark(episodeId: 1, position: 300);

      await repository.deleteBookmark(id);

      final bookmarks = await repository.getBookmarksForEpisode(1);
      expect(bookmarks, isEmpty);
    });

    test('deleteBookmarksForEpisode removes all bookmarks', () async {
      await repository.addBookmark(episodeId: 1, position: 300);
      await repository.addBookmark(episodeId: 1, position: 600);
      await repository.addBookmark(episodeId: 1, position: 900);

      await repository.deleteBookmarksForEpisode(1);

      final bookmarks = await repository.getBookmarksForEpisode(1);
      expect(bookmarks, isEmpty);
    });
  });
}
