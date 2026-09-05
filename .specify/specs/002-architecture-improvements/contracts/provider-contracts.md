# Interface Contracts: Architecture Improvements

**Date**: 2026-09-04

## Provider Contracts

### `appDatabaseProvider`

```dart
/// Provides the singleton AppDatabase instance.
/// 
/// Override in tests:
/// ```dart
/// ProviderScope(
///   overrides: [
///     appDatabaseProvider.overrideWithValue(mockDatabase),
///   ],
///   child: MyApp(),
/// )
/// ```
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});
```

---

### `podcastRepositoryProvider`

```dart
/// Provides PodcastRepository with injected AppDatabase.
/// 
/// Dependencies:
/// - `appDatabaseProvider`
final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return PodcastRepository(database: database);
});
```

---

### `episodeRepositoryProvider`

```dart
/// Provides EpisodeRepository with injected AppDatabase.
/// 
/// Dependencies:
/// - `appDatabaseProvider`
final episodeRepositoryProvider = Provider<EpisodeRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return EpisodeRepository(database: database);
});
```

---

### `bookmarkRepositoryProvider`

```dart
/// Provides BookmarkRepository with injected AppDatabase.
/// 
/// Dependencies:
/// - `appDatabaseProvider`
final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return BookmarkRepository(database: database);
});
```

---

### `userPreferenceRepositoryProvider`

```dart
/// Provides UserPreferenceRepository with injected AppDatabase.
/// 
/// Dependencies:
/// - `appDatabaseProvider`
final userPreferenceRepositoryProvider = Provider<UserPreferenceRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return UserPreferenceRepository(database: database);
});
```

---

### `audioServiceProvider`

```dart
/// Provides AudioService singleton.
/// 
/// Automatically disposed when no longer watched.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});
```

---

### `sleepTimerServiceProvider`

```dart
/// Provides SleepTimerService with injected AudioService.
/// 
/// Dependencies:
/// - `audioServiceProvider`
/// 
/// Automatically disposed when no longer watched.
final sleepTimerServiceProvider = Provider<SleepTimerService>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final service = SleepTimerService(audioService: audioService);
  ref.onDispose(() => service.dispose());
  return service;
});
```

---

### `syncServiceProvider`

```dart
/// Provides SyncService with injected UserPreferenceRepository.
/// 
/// Dependencies:
/// - `userPreferenceRepositoryProvider`
/// 
/// Automatically disposed when no longer watched.
final syncServiceProvider = Provider<SyncService>((ref) {
  final preferenceRepository = ref.watch(userPreferenceRepositoryProvider);
  final service = SyncService(preferenceRepository: preferenceRepository);
  ref.onDispose(() => service.dispose());
  return service;
});
```

---

### `userPreferenceProvider`

```dart
/// Loads user preferences asynchronously.
/// 
/// Returns:
/// - `AsyncData(UserPreference)` on success
/// - `AsyncLoading` while loading
/// - `AsyncError` on failure
final userPreferenceProvider = FutureProvider<UserPreference?>((ref) {
  final repository = ref.watch(userPreferenceRepositoryProvider);
  return repository.getPreferences();
});
```

---

### `playerStateProvider`

```dart
/// Manages current playback state.
/// 
/// Returns `PlayerState?` — null when no episode is loaded.
/// 
/// Dependencies:
/// - `audioServiceProvider`
/// - `episodeRepositoryProvider`
final playerStateProvider =
    StateNotifierProvider<PlayerStateNotifier, PlayerState?>((ref) {
  return PlayerStateNotifier(
    audioService: ref.watch(audioServiceProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
  );
});
```

---

### `downloadedEpisodesProvider`

```dart
/// Stream of downloaded episodes.
/// 
/// Emits updated list whenever episodes are added/removed.
/// 
/// Dependencies:
/// - `episodeRepositoryProvider`
final downloadedEpisodesProvider = StreamProvider<List<Episode>>((ref) {
  final repository = ref.watch(episodeRepositoryProvider);
  return repository.getDownloadedEpisodes();
});
```

---

### `downloadEpisodeProvider`

```dart
/// Manages download state and actions.
/// 
/// State: `DownloadState` with progress map and local paths map.
/// 
/// Actions:
/// - `downloadEpisode(Episode)` — start download
/// - `deleteDownload(Episode)` — delete downloaded file
/// - `isDownloaded(int)` — check if episode is downloaded
/// - `isDownloading(int)` — check if download is in progress
/// 
/// Dependencies:
/// - `episodeRepositoryProvider`
final downloadEpisodeProvider =
    StateNotifierProvider<DownloadController, DownloadState>((ref) {
  return DownloadController(
    episodeRepository: ref.watch(episodeRepositoryProvider),
    downloadService: DownloadService(),
  );
});
```

## Navigation Contracts

### Route: `/`
- **Screen**: `HomeScreen`
- **Parameters**: None
- **Description**: Main screen showing subscribed podcasts

### Route: `/search`
- **Screen**: `SearchScreen`
- **Parameters**: None
- **Description**: Search podcasts via iTunes API

### Route: `/podcast/:id`
- **Screen**: `PodcastDetailScreen`
- **Parameters**: `id` (int) — podcast ID
- **Description**: Podcast details with episode list

### Route: `/player`
- **Screen**: `PlayerScreen`
- **Parameters**: None
- **Description**: Full-screen audio player

### Route: `/downloads`
- **Screen**: `DownloadsScreen`
- **Parameters**: None
- **Description**: Downloaded episodes list

### Route: `/settings`
- **Screen**: `SettingsScreen`
- **Parameters**: None
- **Description**: App settings

## Screen Contracts

### `HomeScreen` → `ConsumerWidget`
- **Watches**: `subscribedPodcastsProvider` (StreamProvider)
- **Navigates**: `context.push('/podcast/${podcast.id}')` on podcast tap

### `SearchScreen` → `ConsumerWidget`
- **Watches**: `searchResultsProvider` (StateNotifierProvider)
- **Navigates**: `context.push('/podcast/${podcast.id}')` on podcast tap

### `PodcastDetailScreen` → `ConsumerWidget`
- **Reads**: `state.pathParameters['id']` for podcast ID
- **Watches**: `podcastProvider(id)`, `episodesProvider(id)`
- **Navigates**: `context.push('/player')` on episode tap (triggers playback)

### `PlayerScreen` → `ConsumerWidget`
- **Watches**: `playerStateProvider`, `sleepTimerServiceProvider`
- **Actions**: play/pause, seek, skip, speed, sleep timer, bookmarks

### `DownloadsScreen` → `ConsumerWidget`
- **Watches**: `downloadedEpisodesProvider`, `downloadEpisodeProvider`
- **Actions**: delete download

### `SettingsScreen` → `ConsumerStatefulWidget`
- **Watches**: `userPreferenceProvider`
- **Actions**: update preferences (optimistic update with rollback)
