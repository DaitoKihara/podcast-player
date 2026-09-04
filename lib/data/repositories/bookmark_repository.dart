import 'package:drift/drift.dart';

import '../datasources/local/app_database.dart';
import '../../domain/entities/app_exception.dart';

/// Repository for bookmark operations.
///
/// Bookmarks allow users to save specific positions within an episode
/// for quick navigation later.
class BookmarkRepository {
  BookmarkRepository({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;

  /// Gets all bookmarks for a specific episode.
  Future<List<Bookmark>> getBookmarksForEpisode(int episodeId) async {
    final db = _database;
    final query = db.select(db.bookmarks)
      ..where((t) => t.episodeId.equals(episodeId))
      ..orderBy([(t) => OrderingTerm.asc(t.position)]);
    return query.get();
  }

  /// Gets a bookmark by its ID.
  Future<Bookmark?> getBookmark(int bookmarkId) async {
    final db = _database;
    final query = db.select(db.bookmarks)
      ..where((t) => t.id.equals(bookmarkId));
    return query.getSingleOrNull();
  }

  /// Adds a new bookmark at the specified position.
  ///
  /// Throws [AppException.validation] if a bookmark already exists at the
  /// exact position for this episode.
  Future<int> addBookmark({
    required int episodeId,
    required int position,
    String? note,
  }) async {
    final db = _database;

    // Check for duplicate bookmark at same position
    final existing = await (db.select(db.bookmarks)
          ..where((t) =>
              t.episodeId.equals(episodeId) & t.position.equals(position)))
        .getSingleOrNull();

    if (existing != null) {
      throw AppException.validation(
        message: 'Bookmark already exists at this position',
      );
    }

    return db.into(db.bookmarks).insert(
          BookmarksCompanion(
            episodeId: Value(episodeId),
            position: Value(position),
            createdAt: Value(DateTime.now()),
            note: Value(note),
          ),
        );
  }

  /// Deletes a bookmark by its ID.
  Future<void> deleteBookmark(int bookmarkId) async {
    final db = _database;
    await (db.delete(db.bookmarks)..where((t) => t.id.equals(bookmarkId))).go();
  }

  /// Deletes all bookmarks for a specific episode.
  Future<void> deleteBookmarksForEpisode(int episodeId) async {
    final db = _database;
    await (db.delete(db.bookmarks)..where((t) => t.episodeId.equals(episodeId))).go();
  }
}
