# Data Model: Polish & Loading Indicator

**Date**: 2026-09-04

## Overview

This refactoring does not introduce new data models. It refines how existing state is managed and displayed.

## State Classes

### EpisodesState (existing)
```dart
class EpisodesState {
  final List<Episode> episodes;
  final bool isLoading;
  final String? error;
}
```

### SearchState (existing)
```dart
class SearchState {
  final String query;
  final List<Podcast> results;
  final bool isLoading;
  final String? error;
}
```

### DownloadState (existing)
```dart
class DownloadState {
  final Map<int, double> progress;
  final Map<int, String> localPaths;
}
```

## Provider Graph (Updated)

```
ProviderScope
├── userPreferenceProvider → FutureProvider<UserPreference?>
│   └── Used by: SettingsScreen, SyncService, DownloadService
├── episodesProvider → StateNotifierProvider.family<EpisodesNotifier, EpisodesState, int>
│   └── Used by: EpisodeList, PodcastDetailScreen (refresh button)
├── downloadEpisodeProvider → StateNotifierProvider<DownloadController, DownloadState>
│   └── Used by: DownloadsScreen
├── downloadServiceProvider → Provider<DownloadService> (NEW)
│   └── Used by: DownloadController
└── searchPodcastsProvider → StateNotifierProvider<SearchPodcastsNotifier, SearchState>
    └── Used by: SearchScreen
```

## Data Flow

### Refresh Button Loading State
1. User taps refresh button in PodcastDetailScreen
2. `_refreshEpisodes()` is called
3. `episodesProvider.refreshEpisodes(rssUrl)` sets `isLoading = true`
4. PodcastDetailScreen watches `episodesProvider` via `ref.watch()`
5. While `isLoading == true`, button is disabled and shows CircularProgressIndicator
6. When refresh completes, `isLoading = false`, button returns to normal

### Settings Screen Migration
1. SettingsScreen watches `userPreferenceProvider` via `ref.watch()`
2. While loading, shows CircularProgressIndicator
3. On error, shows error message with retry button
4. On success, shows preference controls
5. When user changes a setting, calls `ref.read(userPreferenceRepositoryProvider).updatePreferences()`
6. Provider auto-refreshes and UI rebuilds
