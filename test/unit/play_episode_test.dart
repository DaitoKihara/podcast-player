import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/episode_repository.dart';
import 'package:podcast_player/domain/usecases/play_episode.dart';
import 'package:podcast_player/services/audio_service.dart';

void main() {
  group('PlayEpisode', () {
    late AppDatabase database;
    late EpisodeRepository episodeRepository;
    late AudioService audioService;
    late PlayEpisode playEpisode;

    setUp(() {
      database = AppDatabase.forTest(NativeDatabase.memory());
      episodeRepository = EpisodeRepository(database: database);
      audioService = AudioService();
      playEpisode = PlayEpisode(
        episodeRepository: episodeRepository,
        audioService: audioService,
      );
    });

    tearDown(() async {
      await audioService.dispose();
      await database.close();
    });

    test('throws exception when episode not found', () async {
      expect(
        () => playEpisode(999),
        throwsA(isA<Exception>()),
      );
    });

    test('throws exception when no episodes exist', () async {
      // The repository will return an empty list
      expect(
        () => playEpisode(1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
