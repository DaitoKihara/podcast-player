import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull;
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/episode_repository.dart';
import 'package:podcast_player/data/repositories/user_preference_repository.dart';
import 'package:podcast_player/domain/entities/app_exception.dart';
import 'package:podcast_player/domain/usecases/download_episode.dart';
import 'package:podcast_player/services/download_service.dart';

/// Mock DownloadService for testing without actual network calls.
class MockDownloadService extends DownloadService {
  bool wifiConnected = true;
  int mockFileSize = 1024;
  bool shouldThrowOnDownload = false;

  @override
  Future<bool> isWifiConnected() async => wifiConnected;

  @override
  Future<String> download({
    required String url,
    required int episodeId,
    void Function(double progress)? onProgress,
  }) async {
    if (shouldThrowOnDownload) {
      throw DownloadException('Mock download failure');
    }
    onProgress?.call(1.0);
    return '/mock/path/episode_$episodeId.mp3';
  }

  @override
  Future<int> getFileSize(String localPath) async => mockFileSize;

  @override
  Future<void> deleteDownload(String localPath) async {
    // No-op in mock
  }
}

/// Mock UserPreferenceRepository for testing.
class MockUserPreferenceRepository extends UserPreferenceRepository {
  bool wifiOnly = false;

  MockUserPreferenceRepository({required super.database});

  @override
  Future<bool> isWifiOnlyDownloadEnabled() async => wifiOnly;
}

void main() {
  group('DownloadEpisode', () {
    late AppDatabase database;
    late EpisodeRepository episodeRepository;
    late MockDownloadService downloadService;
    late MockUserPreferenceRepository userPreferenceRepository;
    late DownloadEpisode downloadEpisode;

    setUp(() {
      database = AppDatabase.forTest(NativeDatabase.memory());
      episodeRepository = EpisodeRepository(database: database);
      downloadService = MockDownloadService();
      userPreferenceRepository = MockUserPreferenceRepository(database: database);
      downloadEpisode = DownloadEpisode(
        episodeRepository: episodeRepository,
        downloadService: downloadService,
        userPreferenceRepository: userPreferenceRepository,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('throws AppException when episode not found', () async {
      expect(
        () => downloadEpisode.call(episodeId: 999),
        throwsA(isA<AppException>()),
      );
    });

    test('throws WifiRequiredException when Wi-Fi required but not connected',
        () async {
      // Insert an episode
      await database.into(database.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Test Episode'),
              description: const Value('Test Description'),
              audioUrl: const Value('https://example.com/audio.mp3'),
              guid: const Value('test-guid-2'),
              publishDate: Value(DateTime.now()),
            ),
          );

      // Enable Wi-Fi only setting
      userPreferenceRepository.wifiOnly = true;
      // Set Wi-Fi as not connected
      downloadService.wifiConnected = false;

      expect(
        () => downloadEpisode.call(episodeId: 1),
        throwsA(isA<WifiRequiredException>()),
      );
    });

    test('downloads successfully when Wi-Fi is available', () async {
      // Insert an episode
      await database.into(database.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Test Episode'),
              description: const Value('Test Description'),
              audioUrl: const Value('https://example.com/audio.mp3'),
              guid: const Value('test-guid-3'),
              publishDate: Value(DateTime.now()),
            ),
          );

      // Enable Wi-Fi only setting
      userPreferenceRepository.wifiOnly = true;
      // Set Wi-Fi as connected
      downloadService.wifiConnected = true;

      final path = await downloadEpisode.call(episodeId: 1);

      expect(path, isA<String>());
      expect(path, contains('episode_1'));
    });

    test('downloads successfully when Wi-Fi only is disabled', () async {
      // Insert an episode
      await database.into(database.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Test Episode'),
              description: const Value('Test Description'),
              audioUrl: const Value('https://example.com/audio.mp3'),
              guid: const Value('test-guid-4'),
              publishDate: Value(DateTime.now()),
            ),
          );

      // Disable Wi-Fi only setting
      userPreferenceRepository.wifiOnly = false;

      final path = await downloadEpisode.call(episodeId: 1);

      expect(path, isA<String>());
    });

    test('deleteDownload clears download info', () async {
      // Insert an episode with a local path
      await database.into(database.episodes).insert(
            EpisodesCompanion(
              podcastId: const Value(1),
              title: const Value('Test Episode'),
              description: const Value('Test Description'),
              audioUrl: const Value('https://example.com/audio.mp3'),
              guid: const Value('test-guid-5'),
              localPath: const Value('/path/to/delete.mp3'),
              publishDate: Value(DateTime.now()),
            ),
          );

      await downloadEpisode.deleteDownload(1);

      // Verify the episode's localPath is cleared
      final episode = await episodeRepository.getEpisode(1);
      expect(episode?.localPath, null);
    });

    test('deleteDownload does nothing when episode not found', () async {
      // Should not throw
      await downloadEpisode.deleteDownload(999);
    });
  });
}
