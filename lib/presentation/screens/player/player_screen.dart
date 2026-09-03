import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:podcast_player/domain/entities/player_state.dart';
import 'package:podcast_player/presentation/providers/player_provider.dart';
import 'package:podcast_player/core/utils/duration_formatter.dart';

/// Full-screen player interface with comprehensive playback controls.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final audioService = ref.watch(audioServiceProvider);

    if (playerState == null || playerState.episodeId == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Player')),
        body: const Center(
          child: Text('No episode loaded.\nSelect an episode to play.'),
        ),
      );
    }

    final isPlaying = playerState.status == PlayerStatus.playing;
    final isLoading = playerState.status == PlayerStatus.loading;
    final position = Duration(seconds: playerState.position);
    final duration = Duration(seconds: playerState.duration);
    final speed = playerState.speed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player'),
        actions: [
          PopupMenuButton<double>(
            icon: Text('${speed}x'),
            onSelected: audioService.setSpeed,
            itemBuilder: (context) => [
              for (final s in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0])
                PopupMenuItem(
                  value: s.toDouble(),
                  child: Text('${s}x${s == speed ? ' ✓' : ''}'),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.podcasts,
                      size: 120,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Episode ${playerState.episodeId}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble().clamp(1.0, double.infinity),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            audioService.seek(Duration(seconds: value.toInt()));
                          },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDuration(position)),
                        Text(formatDuration(duration)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    iconSize: 40,
                    onPressed: isLoading ? null : audioService.skipBackward,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: IconButton(
                      icon: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 40,
                            ),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (isPlaying) {
                                audioService.pause();
                              } else {
                                audioService.resume();
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.forward_30),
                    iconSize: 40,
                    onPressed: isLoading ? null : audioService.skipForward,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (playerState.status == PlayerStatus.error)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Error: ${playerState.errorMessage ?? 'Unknown error'}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
