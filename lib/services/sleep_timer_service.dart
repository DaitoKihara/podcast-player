import 'dart:async';

import 'package:flutter/foundation.dart';

import 'audio_service.dart';

/// Service for managing a sleep timer that automatically pauses audio playback.
///
/// The sleep timer counts down from a specified duration and pauses the
/// audio service when the timer expires. The remaining time is exposed as
/// a stream for UI updates.
class SleepTimerService {
  /// The audio service to pause when the timer expires.
  final AudioService? _audioService;

  /// Creates a new SleepTimerService.
  ///
  /// The [audioService] is optional and used to pause playback when the
  /// timer expires. If not provided, the timer will still count down
  /// but won't be able to pause audio.
  // ignore: prefer_initializing_formals
  SleepTimerService({AudioService? audioService}) : _audioService = audioService;

  Timer? _timer;
  DateTime? _expiryTime;
  final _remainingTimeController = StreamController<Duration>.broadcast();

  /// Stream of remaining time updates.
  Stream<Duration> get remainingTimeStream => _remainingTimeController.stream;

  /// Current remaining time. Returns Duration.zero if no timer is active.
  Duration get remainingTime {
    final expiry = _expiryTime;
    if (expiry == null) return Duration.zero;
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Whether a sleep timer is currently active.
  bool get isActive => _timer != null && _timer!.isActive;

  /// Sets a sleep timer for the specified duration.
  ///
  /// If a timer is already active, it is cancelled before the new one starts.
  /// When the timer expires, the audio service is paused.
  void setTimer(Duration duration) {
    cancelTimer();

    _expiryTime = DateTime.now().add(duration);
    _remainingTimeController.add(duration);

    _timer = Timer(duration, _onTimerExpired);

    if (kDebugMode) {
      debugPrint('Sleep timer set for ${duration.inMinutes} minutes');
    }
  }

  /// Cancels the active sleep timer.
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _expiryTime = null;
    _remainingTimeController.add(Duration.zero);

    if (kDebugMode) {
      debugPrint('Sleep timer cancelled');
    }
  }

  void _onTimerExpired() {
    if (kDebugMode) {
      debugPrint('Sleep timer expired, pausing audio');
    }

    // Pause audio playback
    _audioService?.pause();

    _timer = null;
    _expiryTime = null;
    _remainingTimeController.add(Duration.zero);
  }

  /// Disposes of the timer resources.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _expiryTime = null;
    _remainingTimeController.close();
  }
}
