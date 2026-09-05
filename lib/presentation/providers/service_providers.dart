import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_player/services/audio_service.dart';
import 'package:podcast_player/services/download_service.dart';
import 'package:podcast_player/services/sleep_timer_service.dart';
import 'package:podcast_player/services/sync_service.dart';
import 'repository_providers.dart';

/// Provider for AudioService singleton.
///
/// Automatically disposed when no longer watched.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for SleepTimerService with injected AudioService.
///
/// Automatically disposed when no longer watched.
final sleepTimerServiceProvider = Provider<SleepTimerService>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final service = SleepTimerService(audioService: audioService);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for SyncService with injected UserPreferenceRepository.
///
/// Automatically disposed when no longer watched.
final syncServiceProvider = Provider<SyncService>((ref) {
  final preferenceRepository = ref.watch(userPreferenceRepositoryProvider);
  final service = SyncService(preferenceRepository: preferenceRepository);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for DownloadService singleton.
///
/// Automatically disposed when no longer watched.
final downloadServiceProvider = Provider<DownloadService>((ref) {
  final service = DownloadService();
  // DownloadService doesn't implement disposable, so no cleanup needed
  return service;
});
