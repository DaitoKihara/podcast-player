import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/user_preference_repository.dart';
import 'package:podcast_player/services/sync_service.dart';

void main() {
  group('SyncService', () {
    late AppDatabase database;
    late UserPreferenceRepository preferenceRepository;
    late SyncService syncService;

    setUp(() {
      database = AppDatabase.forTest(NativeDatabase.memory());
      preferenceRepository = UserPreferenceRepository(database: database);
      syncService = SyncService(preferenceRepository: preferenceRepository);
    });

    tearDown(() async {
      await database.close();
    });

    test('isSyncEnabled returns false when sync is disabled', () async {
      final prefs = await preferenceRepository.getOrCreatePreferences();
      expect(prefs.syncEnabled, false);

      final enabled = await syncService.isSyncEnabled;
      expect(enabled, false);
    });

    test('isSyncEnabled returns false when sync enabled but no auth', () async {
      final prefs = await preferenceRepository.getOrCreatePreferences();
      await preferenceRepository.updatePreferences(
        prefs.copyWith(syncEnabled: true),
      );

      // No auth token set
      final enabled = await syncService.isSyncEnabled;
      expect(enabled, false);
    });

    test('isSyncEnabled returns true when sync enabled and auth set', () async {
      final prefs = await preferenceRepository.getOrCreatePreferences();
      await preferenceRepository.updatePreferences(
        prefs.copyWith(syncEnabled: true),
      );

      syncService.initialize('test-token');

      final enabled = await syncService.isSyncEnabled;
      expect(enabled, true);
    });

    test('syncAll returns disabled when sync is off', () async {
      final result = await syncService.syncAll();
      expect(result, SyncResult.disabled);
    });

    test('signOut clears auth token and disables sync in DB', () async {
      final prefs = await preferenceRepository.getOrCreatePreferences();
      await preferenceRepository.updatePreferences(
        prefs.copyWith(syncEnabled: true),
      );

      syncService.initialize('test-token');
      await syncService.signOut();

      // Sync should be disabled after sign out
      final enabled = await syncService.isSyncEnabled;
      expect(enabled, false);

      // Verify database state is also updated
      final dbPrefs = await preferenceRepository.getPreferences();
      expect(dbPrefs?.syncEnabled, false);
    });

    test('pushSubscriptions returns false (stub)', () async {
      final result = await syncService.pushSubscriptions();
      expect(result, false);
    });

    test('pullSubscriptions returns false (stub)', () async {
      final result = await syncService.pullSubscriptions();
      expect(result, false);
    });

    test('pushPlaybackPositions returns false (stub)', () async {
      final result = await syncService.pushPlaybackPositions();
      expect(result, false);
    });

    test('pullPlaybackPositions returns false (stub)', () async {
      final result = await syncService.pullPlaybackPositions();
      expect(result, false);
    });

    test('syncAll returns pushFailed when sync enabled with stubs', () async {
      final prefs = await preferenceRepository.getOrCreatePreferences();
      await preferenceRepository.updatePreferences(
        prefs.copyWith(syncEnabled: true),
      );
      syncService.initialize('test-token');

      final result = await syncService.syncAll();
      // Stubs return false, so push phase fails
      expect(result, SyncResult.pushFailed);
    });

    test('syncAll returns disabled when auth token is cleared', () async {
      final prefs = await preferenceRepository.getOrCreatePreferences();
      await preferenceRepository.updatePreferences(
        prefs.copyWith(syncEnabled: true),
      );
      syncService.initialize('test-token');
      syncService.signOut();

      final result = await syncService.syncAll();
      expect(result, SyncResult.disabled);
    });
  });
}
