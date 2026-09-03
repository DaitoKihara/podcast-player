import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../../domain/entities/app_exception.dart';

part 'app_database.g.dart';

/// Podcasts table - stores podcast metadata
@DataClassName('Podcast')
class Podcasts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itunesId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get description => text()();
  TextColumn get artworkUrl => text()();
  TextColumn get rssUrl => text()();
  TextColumn get category => text().nullable()();
  IntColumn get episodeCount => integer().nullable()();
  DateTimeColumn get subscribedAt => dateTime()();
  BoolColumn get autoDownload => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();

  @override
  List<String> get customConstraints => ['UNIQUE (itunesId)'];
}

/// Episodes table - stores episode metadata
@DataClassName('Episode')
class Episodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get podcastId => integer()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get audioUrl => text()();
  IntColumn get duration => integer().nullable()();
  DateTimeColumn get publishDate => dateTime()();
  BoolColumn get isPlayed => boolean().withDefault(const Constant(false))();
  IntColumn get playedPosition => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get localPath => text().nullable()();
  TextColumn get guid => text()();

  @override
  List<String> get customConstraints => ['UNIQUE (guid)'];
}

/// Subscriptions table - stores user subscriptions
@DataClassName('Subscription')
class Subscriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get podcastId => integer()();
  DateTimeColumn get subscribedAt => dateTime()();
  BoolColumn get autoDownload => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();

  @override
  List<String> get customConstraints => ['UNIQUE (podcastId)'];
}

/// User preferences table
@DataClassName('UserPreference')
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get skipForwardInterval => integer().withDefault(const Constant(30))();
  IntColumn get skipBackwardInterval => integer().withDefault(const Constant(10))();
  RealColumn get defaultPlaybackSpeed => real().withDefault(const Constant(1.0))();
  BoolColumn get downloadOnlyOnWifi => boolean().withDefault(const Constant(true))();
  BoolColumn get autoDownload => boolean().withDefault(const Constant(false))();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  RealColumn get fontSize => real().withDefault(const Constant(1.0))();
  BoolColumn get syncEnabled => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => ['UNIQUE (id)'];
}

/// Bookmarks table - stores episode bookmarks
@DataClassName('Bookmark')
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get episodeId => integer()();
  IntColumn get position => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE (episodeId, position)'];
}

/// Download records table
@DataClassName('DownloadRecord')
class DownloadRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get episodeId => integer()();
  TextColumn get localPath => text()();
  DateTimeColumn get downloadedAt => dateTime()();
  IntColumn get fileSize => integer()();
  IntColumn get status => integer()();

  @override
  List<String> get customConstraints => ['UNIQUE (episodeId)'];
}

/// Manages the Drift database instance.
@DriftDatabase(tables: [Podcasts, Episodes, Subscriptions, UserPreferences, Bookmarks, DownloadRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._();

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'podcast_player');
  }
}
