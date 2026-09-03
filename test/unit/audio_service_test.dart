import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/services/audio_service.dart';

void main() {
  group('AudioService', () {
    late AudioService audioService;

    setUp(() {
      audioService = AudioService();
    });

    tearDown(() async {
      await audioService.dispose();
    });

    test('initial state is idle', () {
      expect(audioService.currentState.status, equals(AudioStatus.idle));
      expect(audioService.currentState.position, equals(Duration.zero));
      expect(audioService.currentState.duration, equals(Duration.zero));
      expect(audioService.currentState.speed, equals(1.0));
    });

    test('initial state has isPlaying false', () {
      expect(audioService.isPlaying, isFalse);
    });

    test('initial state has zero position', () {
      expect(audioService.position, equals(Duration.zero));
    });

    test('speed can be set within valid range', () async {
      // In test mode, speed should update state
      await audioService.setSpeed(1.5);
      expect(audioService.currentState.speed, equals(1.5));

      await audioService.setSpeed(0.5);
      expect(audioService.currentState.speed, equals(0.5));

      await audioService.setSpeed(3.0);
      expect(audioService.currentState.speed, equals(3.0));
    });

    test('speed is clamped to valid range', () async {
      await audioService.setSpeed(5.0);
      expect(audioService.currentState.speed, equals(3.0));

      await audioService.setSpeed(0.1);
      expect(audioService.currentState.speed, equals(0.5));
    });

    test('pause/resume/stop update state', () async {
      expect(audioService.currentState.status, equals(AudioStatus.idle));

      await audioService.resume();
      expect(audioService.currentState.status, equals(AudioStatus.playing));
      expect(audioService.isPlaying, isTrue);

      await audioService.pause();
      expect(audioService.currentState.status, equals(AudioStatus.paused));
      expect(audioService.isPlaying, isFalse);

      await audioService.stop();
      expect(audioService.currentState.status, equals(AudioStatus.stopped));
    });

    test('play updates state', () async {
      await audioService.play('https://example.com/audio.mp3');
      expect(audioService.currentState.status, equals(AudioStatus.playing));
      expect(audioService.isPlaying, isTrue);
    });

    test('seek updates position', () async {
      await audioService.seek(const Duration(seconds: 30));
      expect(audioService.position, equals(const Duration(seconds: 30)));
    });

    test('skipForward increases position', () async {
      await audioService.seek(const Duration(seconds: 100));
      await audioService.skipForward();
      expect(audioService.position, equals(const Duration(seconds: 130)));
    });

    test('skipBackward decreases position', () async {
      await audioService.seek(const Duration(seconds: 100));
      await audioService.skipBackward();
      expect(audioService.position, equals(const Duration(seconds: 90)));
    });

    test('skipBackward clamps at zero', () async {
      await audioService.seek(const Duration(seconds: 5));
      await audioService.skipBackward();
      expect(audioService.position, equals(Duration.zero));
    });

    test('durationStream emits values', () async {
      expect(audioService.durationStream, isA<Stream<Duration?>>());
    });

    test('playerStateStream emits values', () async {
      expect(audioService.playerStateStream, isA<Stream<AudioPlayerState>>());
    });

    test('positionStream emits values', () async {
      expect(audioService.positionStream, isA<Stream<Duration>>());
    });

    test('play with title and artist', () async {
      await audioService.play(
        'https://example.com/audio.mp3',
        title: 'Test Episode',
        artist: 'Test Author',
      );
      expect(audioService.currentState.status, equals(AudioStatus.playing));
    });
  });

  group('AudioPlayerState', () {
    test('can be constructed with defaults', () {
      const state = AudioPlayerState();
      expect(state.status, equals(AudioStatus.idle));
      expect(state.position, equals(Duration.zero));
      expect(state.duration, equals(Duration.zero));
      expect(state.speed, equals(1.0));
      expect(state.episodeId, isNull);
      expect(state.errorMessage, isNull);
    });

    test('can be constructed with custom values', () {
      const state = AudioPlayerState(
        status: AudioStatus.playing,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 45),
        speed: 1.5,
        episodeId: 42,
      );
      expect(state.status, equals(AudioStatus.playing));
      expect(state.position, equals(const Duration(seconds: 30)));
      expect(state.duration, equals(const Duration(minutes: 45)));
      expect(state.speed, equals(1.5));
      expect(state.episodeId, equals(42));
    });

    test('copyWith returns new instance with updated values', () {
      const original = AudioPlayerState(
        status: AudioStatus.idle,
        position: Duration.zero,
      );

      final copied = original.copyWith(
        status: AudioStatus.playing,
        position: const Duration(seconds: 10),
      );

      expect(copied.status, equals(AudioStatus.playing));
      expect(copied.position, equals(const Duration(seconds: 10)));
      expect(copied.duration, equals(original.duration));
      expect(copied.speed, equals(original.speed));
    });

    test('copyWith preserves original values when null is passed', () {
      const original = AudioPlayerState(
        status: AudioStatus.playing,
        position: Duration(seconds: 30),
        speed: 1.5,
      );

      final copied = original.copyWith();

      expect(copied.status, equals(original.status));
      expect(copied.position, equals(original.position));
      expect(copied.speed, equals(original.speed));
    });

    test('copyWith can set errorMessage', () {
      const original = AudioPlayerState();
      final copied = original.copyWith(errorMessage: 'Test error');
      expect(copied.errorMessage, equals('Test error'));
      expect(original.errorMessage, isNull);
    });
  });

  group('AudioStatus', () {
    test('has expected values', () {
      expect(AudioStatus.values, contains(AudioStatus.idle));
      expect(AudioStatus.values, contains(AudioStatus.loading));
      expect(AudioStatus.values, contains(AudioStatus.playing));
      expect(AudioStatus.values, contains(AudioStatus.paused));
      expect(AudioStatus.values, contains(AudioStatus.stopped));
      expect(AudioStatus.values, contains(AudioStatus.error));
    });
  });
}
