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
    final sleepTimerService = ref.watch(sleepTimerServiceProvider);

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
          // Sleep timer button
          Semantics(
            label: sleepTimerService.isActive
                ? 'Sleep timer active'
                : 'Set sleep timer',
            button: true,
            child: IconButton(
              icon: Icon(
                sleepTimerService.isActive
                    ? Icons.bedtime
                    : Icons.bedtime_outlined,
                color: sleepTimerService.isActive
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: () => _showSleepTimerDialog(context, ref),
            ),
          ),
          Semantics(
            label: 'Playback speed ${speed}x',
            button: true,
            child: PopupMenuButton<double>(
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
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Album artwork',
                  image: true,
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
              ),
              const SizedBox(height: 24),
              Semantics(
                label: 'Episode ${playerState.episodeId}',
                child: Text(
                  'Episode ${playerState.episodeId}',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  Semantics(
                    label: 'Seek bar, ${formatDuration(position)} of ${formatDuration(duration)}',
                    slider: true,
                    child: Slider(
                      value: position.inSeconds.toDouble(),
                      max: duration.inSeconds.toDouble().clamp(1.0, double.infinity),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              audioService.seek(Duration(seconds: value.toInt()));
                            },
                    ),
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
                  Semantics(
                    label: 'Skip backward 10 seconds',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.replay_10),
                      iconSize: 40,
                      onPressed: isLoading ? null : audioService.skipBackward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Semantics(
                      label: isPlaying ? 'Pause' : 'Play',
                      button: true,
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
                  ),
                  const SizedBox(width: 16),
                  Semantics(
                    label: 'Skip forward 30 seconds',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.forward_30),
                      iconSize: 40,
                      onPressed: isLoading ? null : audioService.skipForward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Sleep timer status
              if (sleepTimerService.isActive)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bedtime, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Sleep timer: ${formatDuration(sleepTimerService.remainingTime)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Cancel sleep timer',
                        button: true,
                        child: TextButton(
                          onPressed: () => sleepTimerService.cancelTimer(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              // Bookmark button
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: 'Add bookmark',
                      button: true,
                      child: TextButton.icon(
                        onPressed: () => _addBookmark(context, ref),
                        icon: const Icon(Icons.bookmark_add),
                        label: const Text('Add Bookmark'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      label: 'View bookmarks',
                      button: true,
                      child: TextButton.icon(
                        onPressed: () => _showBookmarksDialog(context, ref),
                        icon: const Icon(Icons.bookmarks),
                        label: const Text('Bookmarks'),
                      ),
                    ),
                  ],
                ),
              ),
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

  void _showSleepTimerDialog(BuildContext context, WidgetRef ref) {
    final timerService = ref.read(sleepTimerServiceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set timer to stop playback after:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TimerButton(
                  label: '5 min',
                  duration: const Duration(minutes: 5),
                  onSelected: (d) {
                    timerService.setTimer(d);
                    Navigator.of(context).pop();
                  },
                ),
                _TimerButton(
                  label: '10 min',
                  duration: const Duration(minutes: 10),
                  onSelected: (d) {
                    timerService.setTimer(d);
                    Navigator.of(context).pop();
                  },
                ),
                _TimerButton(
                  label: '15 min',
                  duration: const Duration(minutes: 15),
                  onSelected: (d) {
                    timerService.setTimer(d);
                    Navigator.of(context).pop();
                  },
                ),
                _TimerButton(
                  label: '30 min',
                  duration: const Duration(minutes: 30),
                  onSelected: (d) {
                    timerService.setTimer(d);
                    Navigator.of(context).pop();
                  },
                ),
                _TimerButton(
                  label: '60 min',
                  duration: const Duration(minutes: 60),
                  onSelected: (d) {
                    timerService.setTimer(d);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            if (timerService.isActive) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  timerService.cancelTimer();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel Timer'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addBookmark(BuildContext context, WidgetRef ref) {
    final playerState = ref.read(playerStateProvider);
    if (playerState == null || playerState.episodeId == 0) return;

    final positionSeconds = playerState.position;

    showDialog(
      context: context,
      builder: (context) {
        final noteController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Bookmark'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Position: ${formatDuration(Duration(seconds: positionSeconds))}'),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final bookmarkRepo = ref.read(bookmarkRepositoryProvider);
                await bookmarkRepo.addBookmark(
                  episodeId: playerState.episodeId,
                  position: positionSeconds,
                  note: noteController.text.isNotEmpty ? noteController.text : null,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmark added')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showBookmarksDialog(BuildContext context, WidgetRef ref) {
    final playerState = ref.read(playerStateProvider);
    if (playerState == null || playerState.episodeId == 0) return;

    final bookmarkRepo = ref.read(bookmarkRepositoryProvider);
    final seekAction = ref.read(seekActionProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bookmarks'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder(
            future: bookmarkRepo.getBookmarksForEpisode(playerState.episodeId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final bookmarks = snapshot.data!;
              if (bookmarks.isEmpty) {
                return const Center(child: Text('No bookmarks yet'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];
                  return ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(formatDuration(Duration(seconds: bookmark.position))),
                    subtitle: bookmark.note != null ? Text(bookmark.note!) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await bookmarkRepo.deleteBookmark(bookmark.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                    onTap: () {
                      // Seek to bookmark position
                      seekAction(
                        Duration(seconds: bookmark.position),
                        episodeId: playerState.episodeId,
                      );
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({
    required this.label,
    required this.duration,
    required this.onSelected,
  });

  final String label;
  final Duration duration;
  final ValueChanged<Duration> onSelected;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => onSelected(duration),
      child: Text(label),
    );
  }
}
