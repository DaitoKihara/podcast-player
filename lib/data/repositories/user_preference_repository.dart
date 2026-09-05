import 'package:drift/drift.dart';

import '../datasources/local/app_database.dart';

/// Repository for user preference operations.
class UserPreferenceRepository {
  UserPreferenceRepository({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;

  /// Get the user preferences.
  ///
  /// Returns the first user preference record, or null if none exists.
  Future<UserPreference?> getPreferences() async {
    final db = _database;
    final query = db.select(db.userPreferences)..limit(1);
    return query.getSingleOrNull();
  }

  /// Get or create default user preferences.
  Future<UserPreference> getOrCreatePreferences() async {
    final existing = await getPreferences();
    if (existing != null) return existing;

    final db = _database;
    final id = await db.into(db.userPreferences).insert(
          const UserPreferencesCompanion(
            skipForwardInterval: Value(30),
            skipBackwardInterval: Value(10),
            defaultPlaybackSpeed: Value(1.0),
            downloadOnlyOnWifi: Value(true),
            autoDownload: Value(false),
            darkMode: Value(false),
            fontSize: Value(1.0),
            syncEnabled: Value(false),
          ),
        );

    return UserPreference(
      id: id,
      skipForwardInterval: 30,
      skipBackwardInterval: 10,
      defaultPlaybackSpeed: 1.0,
      downloadOnlyOnWifi: true,
      autoDownload: false,
      darkMode: false,
      fontSize: 1.0,
      syncEnabled: false,
    );
  }

  /// Update user preferences.
  Future<void> updatePreferences(UserPreference preferences) async {
    final db = _database;
    await (db.update(db.userPreferences)..where((t) => t.id.equals(preferences.id)))
        .write(UserPreferencesCompanion(
      skipForwardInterval: Value(preferences.skipForwardInterval),
      skipBackwardInterval: Value(preferences.skipBackwardInterval),
      defaultPlaybackSpeed: Value(preferences.defaultPlaybackSpeed),
      downloadOnlyOnWifi: Value(preferences.downloadOnlyOnWifi),
      autoDownload: Value(preferences.autoDownload),
      darkMode: Value(preferences.darkMode),
      fontSize: Value(preferences.fontSize),
      syncEnabled: Value(preferences.syncEnabled),
        ));
  }

  /// Check if Wi-Fi only download is enabled.
  Future<bool> isWifiOnlyDownloadEnabled() async {
    final prefs = await getOrCreatePreferences();
    return prefs.downloadOnlyOnWifi;
  }
}
