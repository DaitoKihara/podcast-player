import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state.freezed.dart';

@freezed
sealed class PlayerState with _$PlayerState {
  const factory PlayerState({
    required int episodeId,
    required PlayerStatus status,
    required int position,
    required int duration,
    @Default(1.0) double speed,
  }) = _PlayerState;
}

enum PlayerStatus {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}
