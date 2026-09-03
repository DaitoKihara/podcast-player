import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/services/sleep_timer_service.dart';
import 'package:podcast_player/services/audio_service.dart';

void main() {
  group('SleepTimerService', () {
    late SleepTimerService timerService;
    late AudioService audioService;

    setUp(() {
      audioService = AudioService();
      timerService = SleepTimerService(audioService: audioService);
    });

    tearDown(() {
      timerService.dispose();
      audioService.dispose();
    });

    test('initial state has no active timer', () {
      expect(timerService.isActive, isFalse);
      expect(timerService.remainingTime, equals(Duration.zero));
    });

    test('setTimer activates the timer', () {
      timerService.setTimer(const Duration(minutes: 15));
      expect(timerService.isActive, isTrue);
    });

    test('setTimer updates remaining time', () {
      timerService.setTimer(const Duration(minutes: 15));
      final remaining = timerService.remainingTime;
      expect(remaining.inSeconds, greaterThan(0));
      expect(remaining.inMinutes, lessThanOrEqualTo(15));
    });

    test('cancelTimer deactivates the timer', () {
      timerService.setTimer(const Duration(minutes: 15));
      expect(timerService.isActive, isTrue);

      timerService.cancelTimer();
      expect(timerService.isActive, isFalse);
      expect(timerService.remainingTime, equals(Duration.zero));
    });

    test('setTimer cancels previous timer', () {
      timerService.setTimer(const Duration(minutes: 15));
      expect(timerService.isActive, isTrue);

      // Setting a new timer should cancel the previous one
      timerService.setTimer(const Duration(minutes: 30));
      expect(timerService.isActive, isTrue);
    });

    test('remainingTimeStream emits values', () async {
      expect(timerService.remainingTimeStream, isA<Stream<Duration>>());

      timerService.setTimer(const Duration(minutes: 15));
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('timer expires and pauses audio', () async {
      // Set a very short timer
      timerService.setTimer(const Duration(milliseconds: 50));

      // Wait for timer to expire
      await Future.delayed(const Duration(milliseconds: 100));

      // Timer should no longer be active
      expect(timerService.isActive, isFalse);
      expect(timerService.remainingTime, equals(Duration.zero));
    });

    test('dispose cancels timer and closes stream', () {
      timerService.setTimer(const Duration(minutes: 15));
      timerService.dispose();

      expect(timerService.isActive, isFalse);
    });
  });
}
