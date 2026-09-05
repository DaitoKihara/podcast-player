# Data Model: Architecture Improvements

**Date**: 2026-09-04

## Overview

This refactoring does not introduce new data models. It restructures how existing data flows through the application layers.

## Entity Relationship (Provider Graph)

```
ProviderScope
├── appDatabaseProvider → AppDatabase
├── podcastRepositoryProvider → PodcastRepository
│   └── depends on: appDatabaseProvider
├── episodeRepositoryProvider → EpisodeRepository
│   └── depends on: appDatabaseProvider
├── bookmarkRepositoryProvider → BookmarkRepository
│   └── depends on: appDatabaseProvider
├── userPreferenceRepositoryProvider → UserPreferenceRepository
│   └── depends on: appDatabaseProvider
├── audioServiceProvider → AudioService
├── sleepTimerServiceProvider → SleepTimerService
│   └── depends on: audioServiceProvider
├── syncServiceProvider → SyncService
│   └── depends on: userPreferenceRepositoryProvider
├── userPreferenceProvider → FutureProvider<UserPreference?>
├── playerStateProvider → StateNotifierProvider<PlayerStateNotifier, PlayerState?>
│   └── depends on: audioServiceProvider, episodeRepositoryProvider
├── downloadedEpisodesProvider → StreamProvider<List<Episode>>
│   └── depends on: episodeRepositoryProvider
└── downloadEpisodeProvider → StateNotifierProvider<DownloadController, DownloadState>
    └── depends on: episodeRepositoryProvider, downloadService
```

## Provider Types

| Provider | Type | Purpose |
|----------|------|---------|
| `appDatabaseProvider` | `Provider<AppDatabase>` | Singleton database instance |
| `podcastRepositoryProvider` | `Provider<PodcastRepository>` | Podcast data operations |
| `episodeRepositoryProvider` | `Provider<EpisodeRepository>` | Episode data operations |
| `bookmarkRepositoryProvider` | `Provider<BookmarkRepository>` | Bookmark operations |
| `userPreferenceRepositoryProvider` | `Provider<UserPreferenceRepository>` | User settings |
| `audioServiceProvider` | `Provider<AudioService>` | Audio playback |
| `sleepTimerServiceProvider` | `Provider<SleepTimerService>` | Sleep timer |
| `syncServiceProvider` | `Provider<SyncService>` | Cloud sync |
| `userPreferenceProvider` | `FutureProvider<UserPreference?>` | Load user preferences |
| `playerStateProvider` | `StateNotifierProvider` | Current playback state |
| `downloadedEpisodesProvider` | `StreamProvider<List<Episode>>` | Downloaded episodes list |
| `downloadEpisodeProvider` | `StateNotifierProvider` | Download progress & actions |

## State Classes

### DownloadState (existing)
```dart
class DownloadState {
  final Map<int, double> progress;
  final Map<int, String> localPaths;
}
```

### PlayerState (existing, via freezed)
```dart
@freezed
sealed class PlayerState with _$PlayerState {
  const factory PlayerState({
    required int episodeId,
    required PlayerStatus status,
    required int position,
    required int duration,
    @Default(1.0) double speed,
    String? errorMessage,
  }) = _PlayerState;
}
```

## Data Flow

### Screen Rendering
1. Screen watches a `FutureProvider` or `StreamProvider`
2. Provider calls repository method
3. Repository queries Drift database or remote API
4. Result flows back as `AsyncValue<T>`
5. Screen renders based on `data` / `loading` / `error` state

### User Action
1. Screen calls `ref.read(actionProvider).call(args)`
2. Action updates `StateNotifier` or calls repository
3. Repository updates database
4. Watching providers auto-refresh
5. UI rebuilds with new state

### Navigation
1. Screen calls `context.push('/podcast/$id')`
2. `go_router` resolves route and creates screen widget
3. Screen reads route parameters from `state.pathParameters`
4. Screen watches providers for data
