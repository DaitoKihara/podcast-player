# Research: Polish & Loading Indicator

**Date**: 2026-09-04
**Feature**: Phase 6 Polish — Loading Indicator, Settings Migration, API Cleanup

## Research Tasks & Decisions

### RT-001: Loading Indicator Pattern

**Decision**: Use `episodesProvider.isLoading` in `PodcastDetailScreen` to control refresh button state.

**Rationale**: The `EpisodesNotifier` already has an `isLoading` state. The AppBar refresh button should watch this state and show a `CircularProgressIndicator` while loading.

**Alternatives Considered**:
- Local `StatefulWidget` state — would duplicate existing provider state
- Dedicated `StateNotifier` for refresh state — over-engineering for simple boolean

### RT-002: Settings Screen Migration Strategy

**Decision**: Convert `SettingsScreen` from `ConsumerStatefulWidget` to `ConsumerWidget` using `AsyncValue<UserPreference?>` for state management.

**Rationale**: The `userPreferenceProvider` already returns `AsyncValue<UserPreference?>`. The screen should watch this provider and render based on `data`/`loading`/`error` states, eliminating `setState` calls.

**Alternatives Considered**:
- Keep `ConsumerStatefulWidget` with local state — doesn't achieve the goal of eliminating `setState`
- Use `StateNotifier` for settings — unnecessary complexity

### RT-003: Repository Pattern Cleanup

**Decision**: Use `this._database` initializing formals and replace `Stream.fromFuture()` with `query.watch()`.

**Rationale**: `prefer_initializing_formals` is a simple style fix. `query.watch()` returns a reactive stream that auto-updates when data changes, improving real-time UI updates.

**Alternatives Considered**:
- Keep `Stream.fromFuture()` — misses opportunity for reactive updates
- Suppress lint with ignore comment — doesn't improve code quality

### RT-004: DownloadService Provider Injection

**Decision**: Create `downloadServiceProvider` in `service_providers.dart` and inject via constructor.

**Rationale**: Consistency with other services (AudioService, SleepTimerService, SyncService) that are already injected via providers. Enables test mocking.

**Alternatives Considered**:
- Keep direct instantiation in `DownloadController` — breaks DI pattern
- Pass as parameter in `DownloadController` provider — more boilerplate

### RT-005: RadioGroup Migration

**Decision**: Migrate `RadioListTile` to `RadioGroup` in `settings_screen.dart`.

**Rationale**: Flutter 3.32+ deprecated `RadioListTile`'s `groupValue`/`onChanged` in favor of `RadioGroup` ancestor. Migration eliminates 8 deprecation warnings.

**Alternatives Considered**:
- Suppress deprecation warnings — doesn't future-proof the code
- Use custom radio implementation — unnecessary complexity

## Open Questions

None — all technical decisions are standard Flutter/Riverpod patterns.
