import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/user_preference_repository.dart';

void main() {
  group('UserPreferenceRepository', () {
    late AppDatabase database;
    late UserPreferenceRepository repository;

    setUp(() {
      database = AppDatabase.forTest(NativeDatabase.memory());
      repository = UserPreferenceRepository(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('getPreferences returns null when no preferences exist', () async {
      final prefs = await repository.getPreferences();
      expect(prefs, isNull);
    });

    test('getOrCreatePreferences creates default preferences', () async {
      final prefs = await repository.getOrCreatePreferences();

      expect(prefs.skipForwardInterval, 30);
      expect(prefs.skipBackwardInterval, 10);
      expect(prefs.defaultPlaybackSpeed, 1.0);
      expect(prefs.downloadOnlyOnWifi, true);
      expect(prefs.autoDownload, false);
      expect(prefs.darkMode, false);
      expect(prefs.fontSize, 1.0);
      expect(prefs.syncEnabled, false);
    });

    test('getOrCreatePreferences returns existing preferences', () async {
      // Create first
      final first = await repository.getOrCreatePreferences();

      // Get again
      final second = await repository.getOrCreatePreferences();

      expect(second.id, first.id);
      expect(second.skipForwardInterval, first.skipForwardInterval);
    });

    test('updatePreferences updates values', () async {
      final prefs = await repository.getOrCreatePreferences();

      final updated = prefs.copyWith(
        skipForwardInterval: 60,
        downloadOnlyOnWifi: false,
      );

      await repository.updatePreferences(updated);

      final result = await repository.getPreferences();
      expect(result?.skipForwardInterval, 60);
      expect(result?.downloadOnlyOnWifi, false);
    });

    test('isWifiOnlyDownloadEnabled returns true by default', () async {
      final result = await repository.isWifiOnlyDownloadEnabled();
      expect(result, true);
    });

    test('isWifiOnlyDownloadEnabled returns updated value', () async {
      final prefs = await repository.getOrCreatePreferences();
      await repository.updatePreferences(
        UserPreference(
          id: prefs.id,
          skipForwardInterval: prefs.skipForwardInterval,
          skipBackwardInterval: prefs.skipBackwardInterval,
          defaultPlaybackSpeed: prefs.defaultPlaybackSpeed,
          downloadOnlyOnWifi: false,
          autoDownload: prefs.autoDownload,
          darkMode: prefs.darkMode,
          fontSize: prefs.fontSize,
          syncEnabled: prefs.syncEnabled,
        ),
      );

      final result = await repository.isWifiOnlyDownloadEnabled();
      expect(result, false);
    });
  });
}
