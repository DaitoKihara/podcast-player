import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:podcast_player/data/datasources/local/app_database.dart';
import 'package:podcast_player/data/repositories/episode_repository.dart';
import 'package:podcast_player/domain/entities/player_state.dart';
import 'package:podcast_player/domain/usecases/mark_as_played.dart';
import 'package:podcast_player/services/audio_service.dart';

// Services

/// Provider for the AudioService singleton.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the EpisodeRepository.
final episodeRepositoryProvider = Provider<EpisodeRepository>((ref) {
  return EpisodeRepository(database: AppDatabase.instance);
});

// State

/// Provider for the current player state (audio playback).
final playerStateProvider =
    StateNotifierProvider<PlayerStateNotifier, PlayerState?>((ref) {
  return PlayerStateNotifier(
    audioService: ref.watch(audioServiceProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
  );
});

/// Whether audio is currently playing.
final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(playerStateProvider)?.status == PlayerStatus.playing;
});

/// Current playback position.
final positionProvider = Provider<Duration>((ref) {
  return Duration(seconds: ref.watch(playerStateProvider)?.position ?? 0);
});

/// Current episode duration.
final durationProvider = Provider<Duration>((ref) {
  return Duration(seconds: ref.watch(playerStateProvider)?.duration ?? 0);
});

/// Current playback speed.
final speedProvider = Provider<double>((ref) {
  return ref.watch(playerStateProvider)?.speed ?? 1.0;
});

// Actions

/// Provider for playing an episode by ID.
final playEpisodeProvider = Provider<PlayEpisodeAction>((ref) {
  return PlayEpisodeAction(
    audioService: ref.watch(audioServiceProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
  );
});

/// Provider for seeking to a position.
final seekActionProvider = Provider<SeekAction>((ref) {
  return SeekAction(
    audioService: ref.watch(audioServiceProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
  );
});

/// Provider for toggling play/pause.
final togglePlayPauseProvider = Provider<TogglePlayPause>((ref) {
  return TogglePlayPause(audioService: ref.watch(audioServiceProvider));
});

/// Provider for setting playback speed.
final setSpeedProvider = Provider<SetSpeedAction>((ref) {
  return SetSpeedAction(audioService: ref.watch(audioServiceProvider));
});

/// Provider for skipping forward.
final skipForwardProvider = Provider<SkipForwardAction>((ref) {
  return SkipForwardAction(audioService: ref.watch(audioServiceProvider));
});

/// Provider for skipping backward.
final skipBackwardProvider = Provider<SkipBackwardAction>((ref) {
  return SkipBackwardAction(audioService: ref.watch(audioServiceProvider));
});

/// Provider for marking episode as played.
final markAsPlayedProvider = Provider<MarkAsPlayedAction>((ref) {
  return MarkAsPlayedAction(
    markAsPlayed: MarkAsPlayed(),
    episodeRepository: ref.watch(episodeRepositoryProvider),
  );
});

/// Provider for toggling episode favorite.
final toggleFavoriteProvider = Provider<ToggleFavoriteAction>((ref) {
  return ToggleFavoriteAction(
    episodeRepository: ref.watch(episodeRepositoryProvider),
  );
});

// Notifier

/// Notifier that manages player state and syncs with AudioService.
class PlayerStateNotifier extends StateNotifier<PlayerState?> {
  PlayerStateNotifier({
    required this.audioService,
    required this.episodeRepository,
  }) : super(null) {
    _init();
  }

  final AudioService audioService;
  final EpisodeRepository episodeRepository;

  StreamSubscription<AudioPlayerState>? _stateSubscription;

  void _init() {
    _stateSubscription = audioService.playerStateStream.listen((audioState) {
      state = PlayerState(
        episodeId: audioState.episodeId ?? 0,
        status: _mapStatus(audioState.status),
        position: audioState.position.inSeconds,
        duration: audioState.duration.inSeconds,
        speed: audioState.speed,
      );
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  PlayerStatus _mapStatus(AudioStatus status) {
    switch (status) {
      case AudioStatus.idle:
        return PlayerStatus.idle;
      case AudioStatus.loading:
        return PlayerStatus.loading;
      case AudioStatus.playing:
        return PlayerStatus.playing;
      case AudioStatus.paused:
        return PlayerStatus.paused;
      case AudioStatus.stopped:
        return PlayerStatus.stopped;
      case AudioStatus.error:
        return PlayerStatus.error;
    }
  }
}

// Actions

/// Action to play an episode.
class PlayEpisodeAction {
  PlayEpisodeAction({
    required this.audioService,
    required this.episodeRepository,
  });

  final AudioService audioService;
  final EpisodeRepository episodeRepository;

  Future<void> call(int episodeId) async {
    final episodes = await episodeRepository.getEpisodes(episodeId);
    final episode = episodes.isEmpty ? null : episodes.first;

    if (episode == null) return;

    await audioService.play(
      episode.audioUrl,
      startPosition: Duration(seconds: episode.playedPosition),
      title: episode.title,
    );
  }
}

/// Action to seek to a position.
class SeekAction {
  SeekAction({
    required this.audioService,
    required this.episodeRepository,
  });

  final AudioService audioService;
  final EpisodeRepository episodeRepository;

  Future<void> call(Duration position, {int? episodeId}) async {
    await audioService.seek(position);

    // Update position in database
    if (episodeId != null) {
      await episodeRepository.updatePosition(episodeId, position.inSeconds);
    }
  }
}

/// Action to toggle play/pause.
class TogglePlayPause {
  TogglePlayPause({required this.audioService});

  final AudioService audioService;

  Future<void> call() async {
    if (audioService.isPlaying) {
      await audioService.pause();
    } else {
      await audioService.resume();
    }
  }
}

/// Action to set playback speed.
class SetSpeedAction {
  SetSpeedAction({required this.audioService});

  final AudioService audioService;

  Future<void> call(double speed) async {
    await audioService.setSpeed(speed);
  }
}

/// Action to skip forward.
class SkipForwardAction {
  SkipForwardAction({required this.audioService});

  final AudioService audioService;

  Future<void> call([Duration? duration]) async {
    await audioService.skipForward(duration ?? const Duration(seconds: 30));
  }
}

/// Action to skip backward.
class SkipBackwardAction {
  SkipBackwardAction({required this.audioService});

  final AudioService audioService;

  Future<void> call([Duration? duration]) async {
    await audioService.skipBackward(duration ?? const Duration(seconds: 10));
  }
}

/// Action to mark an episode as played with 90% threshold.
class MarkAsPlayedAction {
  MarkAsPlayedAction({
    required this.markAsPlayed,
    required this.episodeRepository,
  });

  final MarkAsPlayed markAsPlayed;
  final EpisodeRepository episodeRepository;

  Future<bool> call({
    required int episodeId,
    required int positionSeconds,
    required int durationSeconds,
  }) {
    return markAsPlayed.call(
      episodeId: episodeId,
      positionSeconds: positionSeconds,
      durationSeconds: durationSeconds,
    );
  }
}

/// Action to toggle the favorite status of an episode.
class ToggleFavoriteAction {
  ToggleFavoriteAction({required this.episodeRepository});

  final EpisodeRepository episodeRepository;

  Future<void> call(int episodeId) {
    return episodeRepository.toggleFavorite(episodeId);
  }
}
