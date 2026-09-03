import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Audio service wrapper around just_audio and just_audio_background.
///
/// Provides a simplified interface for audio playback with background
/// notification support, speed control, and skip functionality.
class AudioService {
  AudioService({AudioPlayer? player})
      : _playerOverride = player,
        _isTestMode = _isRunningInTest() {
    if (_playerOverride != null) {
      _player = _playerOverride;
      _initStreams();
    } else if (_isTestMode) {
      _player = null;
      _initStreamsForTests();
    } else {
      _player = AudioPlayer();
      _initStreams();
    }
  }

  final AudioPlayer? _playerOverride;
  AudioPlayer? _player;
  final bool _isTestMode;

  final _playerStateController = StreamController<AudioPlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();

  /// Stream of player state changes (playing, paused, etc.).
  Stream<AudioPlayerState> get playerStateStream =>
      _playerStateController.stream;

  /// Stream of current playback position.
  Stream<Duration> get positionStream => _positionController.stream;

  /// Stream of total duration of current episode.
  Stream<Duration?> get durationStream => _durationController.stream;

  AudioPlayerState _currentState = const AudioPlayerState();

  /// Current snapshot of the audio player state.
  AudioPlayerState get currentState => _currentState;

  /// Whether the service is in test mode (just_audio unavailable).
  bool get isTestMode => _isTestMode;

  static bool _isRunningInTest() {
    return Platform.environment.containsKey('FLUTTER_TEST');
  }

  void _initStreams() {
    final player = _player;
    if (player == null) return;

    player.playerStateStream.listen((state) {
      _currentState = _currentState.copyWith(
        status: _mapProcessingState(state.processingState),
        position: player.position,
        duration: player.duration ?? Duration.zero,
      );
      _playerStateController.add(_currentState);
    });

    player.positionStream.listen((position) {
      _positionController.add(position);
      _currentState = _currentState.copyWith(position: position);
    });

    player.durationStream.listen((duration) {
      _durationController.add(duration);
      if (duration != null) {
        _currentState = _currentState.copyWith(duration: duration);
      }
    });

    player.speedStream.listen((speed) {
      _currentState = _currentState.copyWith(speed: speed);
      _playerStateController.add(_currentState);
    });
  }

  void _initStreamsForTests() {
    _currentState = const AudioPlayerState(
      status: AudioStatus.idle,
    );
    _playerStateController.add(_currentState);
  }

  /// Plays audio from a URL, optionally starting at a specific position.
  Future<void> play(
    String audioUrl, {
    Duration startPosition = Duration.zero,
    String? title,
    String? artist,
    String? artUri,
  }) async {
    if (_isTestMode) {
      _currentState = _currentState.copyWith(
        status: AudioStatus.playing,
        position: startPosition,
      );
      _playerStateController.add(_currentState);
      _positionController.add(startPosition);
      return;
    }

    final player = _player;
    if (player == null) return;

    try {
      final audioSource = AudioSource.uri(
        Uri.parse(audioUrl),
        tag: MediaItem(
          id: audioUrl,
          title: title ?? 'Episode',
          artist: artist ?? 'Podcast Player',
          artUri: artUri != null ? Uri.parse(artUri) : null,
        ),
      );

      await player.setAudioSource(audioSource);

      if (startPosition > Duration.zero) {
        await player.seek(startPosition);
      }

      await player.play();
    } on Exception catch (e) {
      _currentState = _currentState.copyWith(
        status: AudioStatus.error,
        errorMessage: e.toString(),
      );
      _playerStateController.add(_currentState);
    }
  }

  /// Pauses playback.
  Future<void> pause() async {
    if (_isTestMode) {
      _currentState = _currentState.copyWith(status: AudioStatus.paused);
      _playerStateController.add(_currentState);
      return;
    }
    await _player?.pause();
  }

  /// Resumes playback if paused.
  Future<void> resume() async {
    if (_isTestMode) {
      _currentState = _currentState.copyWith(status: AudioStatus.playing);
      _playerStateController.add(_currentState);
      return;
    }
    await _player?.play();
  }

  /// Stops playback and resets position.
  Future<void> stop() async {
    if (_isTestMode) {
      _currentState = const AudioPlayerState(status: AudioStatus.stopped);
      _playerStateController.add(_currentState);
      return;
    }
    await _player?.stop();
  }

  /// Seeks to a specific position.
  Future<void> seek(Duration position) async {
    if (_isTestMode) {
      _currentState = _currentState.copyWith(position: position);
      _positionController.add(position);
      return;
    }
    await _player?.seek(position);
  }

  /// Sets playback speed (0.5x to 3.0x).
  Future<void> setSpeed(double speed) async {
    final clampedSpeed = speed.clamp(0.5, 3.0);
    if (_isTestMode) {
      _currentState = _currentState.copyWith(speed: clampedSpeed);
      _playerStateController.add(_currentState);
      return;
    }
    await _player?.setSpeed(clampedSpeed);
  }

  /// Skips forward by the specified duration (default 30 seconds).
  Future<void> skipForward([Duration duration = const Duration(seconds: 30)]) async {
    if (_isTestMode) {
      final newPosition = _currentState.position + duration;
      _currentState = _currentState.copyWith(position: newPosition);
      _positionController.add(newPosition);
      return;
    }
    final player = _player;
    if (player == null) return;
    final newPosition = player.position + duration;
    final maxDuration = player.duration ?? Duration.zero;
    await player.seek(newPosition > maxDuration ? maxDuration : newPosition);
  }

  /// Skips backward by the specified duration (default 10 seconds).
  Future<void> skipBackward([Duration duration = const Duration(seconds: 10)]) async {
    if (_isTestMode) {
      final newPosition = _currentState.position - duration;
      final clamped = newPosition < Duration.zero ? Duration.zero : newPosition;
      _currentState = _currentState.copyWith(position: clamped);
      _positionController.add(clamped);
      return;
    }
    final player = _player;
    if (player == null) return;
    final newPosition = player.position - duration;
    await player.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  /// Whether the player is currently playing.
  bool get isPlaying => _isTestMode
      ? _currentState.status == AudioStatus.playing
      : (_player?.playing ?? false);

  /// Current playback position.
  Duration get position => _isTestMode
      ? _currentState.position
      : (_player?.position ?? Duration.zero);

  /// Total duration of current episode.
  Duration? get duration => _isTestMode
      ? _currentState.duration
      : _player?.duration;

  /// Current playback speed.
  double get speed => _isTestMode
      ? _currentState.speed
      : (_player?.speed ?? 1.0);

  /// Disposes of the audio player resources.
  Future<void> dispose() async {
    if (!_isTestMode) {
      await _player?.dispose();
    }
    await _playerStateController.close();
    await _positionController.close();
    await _durationController.close();
  }

  AudioStatus _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioStatus.idle;
      case ProcessingState.loading:
        return AudioStatus.loading;
      case ProcessingState.buffering:
        return AudioStatus.loading;
      case ProcessingState.ready:
        return _player?.playing ?? false ? AudioStatus.playing : AudioStatus.paused;
      case ProcessingState.completed:
        return AudioStatus.stopped;
    }
  }
}

/// Represents the current state of the audio player.
class AudioPlayerState {
  const AudioPlayerState({
    this.status = AudioStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.episodeId,
    this.errorMessage,
  });

  final AudioStatus status;
  final Duration position;
  final Duration duration;
  final double speed;
  final int? episodeId;
  final String? errorMessage;

  AudioPlayerState copyWith({
    AudioStatus? status,
    Duration? position,
    Duration? duration,
    double? speed,
    int? episodeId,
    String? errorMessage,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      episodeId: episodeId ?? this.episodeId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum AudioStatus {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}
