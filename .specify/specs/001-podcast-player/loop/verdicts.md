# Verdicts — Loop Phase 5: Episode Management

**Checked by:** Independent Checker  
**Date:** 2026-09-03  
**Branch:** `feature/phase5-episode-management`

---

## D1: 90%再生で自動的に既聴マーク — ⚠️ PARTIALLY PASS

### Evidence

**`lib/domain/usecases/mark_as_played.dart`** — ✅ PASS
- 90% threshold logic present: `positionSeconds >= durationSeconds * 0.9`
- Static helper `isThresholdMet()` with edge case handling (duration <= 0 returns false)
- Correctly calls `markAsPlayed` when threshold met, `updatePosition` otherwise

**`lib/presentation/providers/player_provider.dart`** — ⚠️ PARTIAL
- `MarkAsPlayedAction` class exists (lines 256-276) ✅
- `markAsPlayedProvider` exists (lines 95-100) ✅
- **BUT:** `PlayerStateNotifier._init()` only listens to `audioService.playerStateStream` and updates local state. It does **NOT** automatically invoke `markAsPlayed` when playback ends or when position reaches 90%.
- The contract requires: "PlayerProviderが再生終了時に自動的に判定して呼び出す" — this automatic triggering is **missing**.

**Unit tests** — ✅ PASS
- `test/unit/mark_as_played_test.dart` exists with 5 test cases
- Tests cover: duration=0, below 90%, exactly 90%, above 90%, 100%
- All tests pass

### Verdict
The 90% threshold logic is correctly implemented in the use case, but the **automatic invocation** from PlayerProvider is missing. The action is defined but never wired to playback completion events. This is a partial implementation.

---

## D2: お気に入りトグル — ⚠️ PARTIALLY PASS

### Evidence

**`ToggleFavoriteAction` in player_provider.dart** — ✅ PASS
- Class exists (lines 279-287)
- Delegates to `episodeRepository.toggleFavorite(episodeId)`
- `toggleFavoriteProvider` defined (lines 103-107)

**`EpisodeRepository.toggleFavorite()`** — ✅ PASS
- Exists in `lib/data/repositories/episode_repository.dart` (lines 103-118)
- Correctly flips `isFavorite` boolean
- Throws `AppException` if episode not found

**Unit tests** — ⚠️ PARTIAL
- Contract requires: `test/unit/toggle_favorite_test.dart`
- This file does **NOT exist**
- However, `test/unit/episode_repository_test.dart` contains `toggleFavorite flips favorite status` test (lines 127-147) which passes
- The contract explicitly lists `test/unit/toggle_favorite_test.dart` as a new file to create — this was not done

### Verdict
Functionality works correctly, but the dedicated unit test file specified in the contract is missing. The test exists in a different file.

---

## D3: 新着エピソード検出 — ✅ PASS

### Evidence

**`EpisodeRepository.getNewEpisodes()`** — ✅ PASS
- Exists in `lib/data/repositories/episode_repository.dart` (lines 147-153)
- Returns `Stream<List<Episode>>`
- Filters by `isPlayed == false` for the given podcastId
- Ordered by `publishDate` descending

**NEW badge in EpisodeTile** — ✅ PASS
- `lib/presentation/widgets/episode_tile.dart` lines 84-101
- Shows "NEW" badge when `isNew && !isPlayed`
- Styled with primary color background and bold white text

**PodcastDetailScreen integration** — ✅ PASS
- Uses `EpisodeList` widget which renders `EpisodeTile` for each episode
- `isNew` is computed in `EpisodeList` (lines 151-155): `!episode.isPlayed && DateTime.now().difference(episode.publishDate).inDays < 7`

### Verdict
Fully implemented. The NEW badge is displayed through the EpisodeTile within the EpisodeList on the PodcastDetailScreen.

---

## D4: EpisodeTile ウィジェット — ✅ PASS

### Evidence

**File:** `lib/presentation/widgets/episode_tile.dart` (177 lines)

| Requirement | Status | Location |
|-------------|--------|----------|
| Play indicator | ✅ | `_buildLeadingIcon()` lines 125-145: play_circle_filled (playing), check_circle (played), play_circle_outline (default) |
| Favorite toggle | ✅ | IconButton lines 107-114: Icons.favorite / Icons.favorite_border with red color |
| Long-press menu | ✅ | `onLongPress` → `_showContextMenu()` lines 147-176: bottom sheet with mark played/unplayed |
| isNew state | ✅ | Parameter + NEW badge display lines 84-101 |
| isPlayed state | ✅ | Parameter + greyed out / strikethrough text lines 72-75 |
| isFavorite state | ✅ | Parameter + filled/outline heart icon lines 109-110 |

### Verdict
All required features are present and correctly implemented.

---

## D5: エピソード一覧フィルター — ✅ PASS

### Evidence

**File:** `lib/presentation/widgets/episode_list.dart` (252 lines)

| Requirement | Status | Location |
|-------------|--------|----------|
| Filter: All | ✅ | `EpisodeFilter.all` + FilterChip line 173-177 |
| Filter: Unread | ✅ | `EpisodeFilter.unread` + FilterChip line 179-184 |
| Filter: Favorites | ✅ | `EpisodeFilter.favorites` + FilterChip line 186-191 |
| Sort: Newest | ✅ | `EpisodeSort.newestFirst` + TextButton line 203-213 |
| Sort: Oldest | ✅ | `EpisodeSort.oldestFirst` + TextButton line 214-224 |

### Verdict
All filter and sort options are implemented and functional.

---

## D6: flutter analyze — ✅ PASS

### Evidence

```
$ flutter analyze
No issues found! (ran in 0.6s)
Exit code: 0
```

```
$ flutter test
All tests passed!
Exit code: 0
Total: 52 tests
```

### Verdict
Clean analyze, all tests pass.

---

## Summary

| Criterion | Verdict | Notes |
|-----------|---------|-------|
| D1 | ⚠️ PARTIAL | Auto-trigger on playback end missing |
| D2 | ⚠️ PARTIAL | Dedicated test file missing |
| D3 | ✅ PASS | Fully implemented |
| D4 | ✅ PASS | All features present |
| D5 | ✅ PASS | All filters/sorts present |
| D6 | ✅ PASS | Clean analyze + all tests pass |

### Issues Found

1. **D1 — Missing automatic invocation:** `PlayerStateNotifier` does not call `markAsPlayed` when playback completes or reaches 90%. The action/provider exists but is never triggered automatically. This is the contract's primary requirement.

2. **D2 — Missing test file:** `test/unit/toggle_favorite_test.dart` was not created as specified in the contract. The test exists in `episode_repository_test.dart` instead.

### Recommendation

The loop should **not** be marked as fully done. The maker needs to:
1. Wire `markAsPlayed` invocation into `PlayerStateNotifier` (e.g., listen for position/duration changes and auto-mark at 90%)
2. Create the dedicated `test/unit/toggle_favorite_test.dart` file
