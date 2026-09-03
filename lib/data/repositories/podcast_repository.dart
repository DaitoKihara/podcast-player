import 'package:drift/drift.dart';

import '../datasources/local/app_database.dart';
import '../datasources/remote/itunes_api_client.dart';
import '../../domain/entities/app_exception.dart';
import '../../domain/entities/podcast_search_query.dart';

/// Repository for podcast operations.
class PodcastRepository {
  PodcastRepository({
    ITunesApiClient? apiClient,
    AppDatabase? database,
  })  : _apiClient = apiClient ?? ITunesApiClient(),
        _database = database ?? AppDatabase.instance;

  final ITunesApiClient _apiClient;
  final AppDatabase _database;

  /// Searches for podcasts via iTunes API.
  Future<List<Podcast>> search(PodcastSearchQuery query) async {
    if (query.term.isEmpty) {
      return <Podcast>[];
    }
    try {
      final results = await _apiClient.searchPodcasts(
        term: query.term,
        limit: query.limit,
        offset: query.offset,
      );

      return results
          .map((r) => Podcast(
                id: 0,
                itunesId: r.collectionId,
                title: r.collectionName ?? '',
                author: r.artistName ?? '',
                description: '',
                artworkUrl: r.artworkUrl600 ?? '',
                rssUrl: r.feedUrl ?? '',
                category: r.genres?.firstOrNull,
                episodeCount: r.trackCount,
                subscribedAt: DateTime.now(),
                autoDownload: false,
                notificationsEnabled: true,
              ))
          .toList();
    } catch (e) {
      if (e is AppException) rethrow;
      // ignore: only_throw_errors
      throw AppException.network(
        message: 'Search failed',
        originalError: e,
      );
    }
  }

  /// Gets a podcast by ID.
  Future<Podcast?> getById(int id) async {
    final db = _database;
    final query = db.select(db.podcasts)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Subscribes to a podcast by ID (fetches data first).
  Future<void> subscribeById(int podcastId) async {
    final db = _database;
    final query = db.select(db.podcasts)..where((t) => t.id.equals(podcastId));
    final podcast = await query.getSingle();
    await subscribe(podcast);
  }

  /// Subscribes to a podcast.
  Future<int> subscribe(Podcast podcast) async {
    final db = _database;

    final podcastId = await db.into(db.podcasts).insert(
          PodcastsCompanion(
            itunesId: Value(podcast.itunesId),
            title: Value(podcast.title),
            author: Value(podcast.author),
            description: Value(podcast.description),
            artworkUrl: Value(podcast.artworkUrl),
            rssUrl: Value(podcast.rssUrl),
            category: Value(podcast.category),
            episodeCount: Value(podcast.episodeCount),
            subscribedAt: Value(podcast.subscribedAt),
            autoDownload: Value(podcast.autoDownload),
            notificationsEnabled: Value(podcast.notificationsEnabled),
          ),
        );

    await db.into(db.subscriptions).insert(
          SubscriptionsCompanion(
            podcastId: Value(podcastId),
            subscribedAt: Value(DateTime.now()),
            autoDownload: const Value(false),
            notificationsEnabled: const Value(true),
          ),
        );

    return podcastId;
  }

  /// Unsubscribes from a podcast.
  Future<void> unsubscribe(int podcastId) async {
    final db = _database;
    await (db.delete(db.subscriptions)..where((t) => t.podcastId.equals(podcastId))).go();
    await (db.delete(db.podcasts)..where((t) => t.id.equals(podcastId))).go();
  }

  /// Gets a subscription by podcast ID.
  Future<Subscription?> getSubscription(int podcastId) async {
    final db = _database;
    final query = db.select(db.subscriptions)..where((t) => t.podcastId.equals(podcastId));
    return query.getSingleOrNull();
  }

  /// Gets all subscribed podcasts.
  Stream<List<Podcast>> get subscribedPodcasts {
    final db = _database;
    final query = db.select(db.podcasts)
      ..orderBy([(t) => OrderingTerm.desc(t.subscribedAt)]);
    return Stream.fromFuture(query.get());
  }
}
