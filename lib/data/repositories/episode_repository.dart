import 'package:drift/drift.dart';

import '../datasources/local/app_database.dart';
import '../datasources/remote/rss_feed_parser.dart';
import '../../domain/entities/app_exception.dart';

/// Repository for episode operations.
class EpisodeRepository {
  EpisodeRepository({
    RssFeedParser? rssParser,
    required AppDatabase database,
  })  : _rssParser = rssParser ?? RssFeedParser(),
        _database = database;

  final RssFeedParser _rssParser;
  final AppDatabase _database;

  /// Gets episodes for a specific podcast.
  Future<List<Episode>> getEpisodes(int podcastId) async {
    final db = _database;
    final query = db.select(db.episodes)
      ..where((t) => t.podcastId.equals(podcastId))
      ..orderBy([(t) => OrderingTerm.desc(t.publishDate)]);
    return query.get();
  }

  /// Gets episodes for a specific podcast with fresh RSS data.
  Future<List<Episode>> refreshEpisodes(int podcastId, String rssUrl) async {
    try {
      final result = await _rssParser.parseFeed(rssUrl);
      final db = _database;

      // Get existing episodes to avoid duplicates
      final existingEpisodes = await getEpisodes(podcastId);
      final existingGuides = existingEpisodes.map((e) => e.guid).toSet();

      final newEpisodes = <Episode>[];
      for (final info in result.episodes) {
        if (!existingGuides.contains(info.guid)) {
          final episodeId = await db.into(db.episodes).insert(
                EpisodesCompanion(
                  podcastId: Value(podcastId),
                  title: Value(info.title),
                  description: Value(info.description),
                  audioUrl: Value(info.audioUrl),
                  duration: Value(info.duration),
                  publishDate: Value(info.publishDate),
                  guid: Value(info.guid),
                  isPlayed: const Value(false),
                  playedPosition: const Value(0),
                  isFavorite: const Value(false),
                ),
              );
          newEpisodes.add(Episode(
            id: episodeId,
            podcastId: podcastId,
            title: info.title,
            description: info.description,
            audioUrl: info.audioUrl,
            duration: info.duration,
            publishDate: info.publishDate,
            guid: info.guid,
            isPlayed: false,
            playedPosition: 0,
            isFavorite: false,
          ));
        }
      }

      return newEpisodes;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.feedParse(
        message: 'Failed to refresh episodes',
        originalError: e,
      );
    }
  }

  /// Marks an episode as played.
  Future<void> markAsPlayed(int episodeId, int position) async {
    final db = _database;
    await (db.update(db.episodes)..where((t) => t.id.equals(episodeId))).write(
          EpisodesCompanion(
            isPlayed: const Value(true),
            playedPosition: Value(position),
          ),
        );
  }

  /// Marks an episode as unplayed.
  Future<void> markAsUnplayed(int episodeId) async {
    final db = _database;
    await (db.update(db.episodes)..where((t) => t.id.equals(episodeId))).write(
          const EpisodesCompanion(
            isPlayed: Value(false),
            playedPosition: Value(0),
          ),
        );
  }

  /// Toggles the favorite status of an episode.
  Future<void> toggleFavorite(int episodeId) async {
    final db = _database;
    final episode = await (db.select(db.episodes)
          ..where((t) => t.id.equals(episodeId)))
        .getSingleOrNull();
    if (episode == null) {
      throw AppException.storage(
        message: 'Episode not found',
      );
    }
    await (db.update(db.episodes)..where((t) => t.id.equals(episodeId))).write(
          EpisodesCompanion(
            isFavorite: Value(!episode.isFavorite),
          ),
        );
  }

  /// Updates the playback position of an episode.
  Future<void> updatePosition(int episodeId, int position) async {
    final db = _database;
    await (db.update(db.episodes)..where((t) => t.id.equals(episodeId))).write(
          EpisodesCompanion(
            playedPosition: Value(position),
          ),
        );
  }

  /// Gets an episode by GUID.
  Future<Episode?> getByGuid(String guid) async {
    final db = _database;
    final query = db.select(db.episodes)
      ..where((t) => t.guid.equals(guid));
    return query.getSingleOrNull();
  }

  /// Gets an episode by its ID.
  Future<Episode?> getEpisode(int episodeId) async {
    final db = _database;
    final query = db.select(db.episodes)
      ..where((t) => t.id.equals(episodeId));
    return query.getSingleOrNull();
  }

  /// Marks an episode as downloaded with local path and file size.
  Future<void> markAsDownloaded(int episodeId, String localPath, int fileSize) async {
    final db = _database;
    await (db.update(db.episodes)..where((t) => t.id.equals(episodeId))).write(
          EpisodesCompanion(
            localPath: Value(localPath),
          ),
        );
    await db.into(db.downloadRecords).insert(
          DownloadRecordsCompanion(
            episodeId: Value(episodeId),
            localPath: Value(localPath),
            downloadedAt: Value(DateTime.now()),
            fileSize: Value(fileSize),
            status: const Value(2), // completed
          ),
        );
  }

  /// Clears download info for an episode.
  Future<void> clearDownloadInfo(int episodeId) async {
    final db = _database;
    await (db.update(db.episodes)..where((t) => t.id.equals(episodeId))).write(
          const EpisodesCompanion(
            localPath: Value(null),
          ),
        );
    await (db.delete(db.downloadRecords)..where((t) => t.episodeId.equals(episodeId))).go();
  }

  /// Gets downloaded episodes.
  Stream<List<Episode>> getDownloadedEpisodes() {
    final db = _database;
    final query = db.select(db.episodes)
      ..where((t) => t.localPath.isNotNull());
    return Stream.fromFuture(query.get());
  }

  /// Gets new (unplayed) episodes for a podcast.
  Stream<List<Episode>> getNewEpisodes(int podcastId) {
    final db = _database;
    final query = db.select(db.episodes)
      ..where((t) => t.podcastId.equals(podcastId) & t.isPlayed.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.publishDate)]);
    return Stream.fromFuture(query.get());
  }
}
