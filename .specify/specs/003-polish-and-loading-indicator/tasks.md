# Tasks: Polish & Loading Indicator

**Input**: Design documents from `/specs/003-polish-and-loading-indicator/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: No tests explicitly requested — existing 101 tests must remain green.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize Dart project with Riverpod dependencies
- [ ] T003 [P] Configure linting and formatting tools

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Create `downloadServiceProvider` in `lib/presentation/providers/service_providers.dart`
- [ ] T005 Update `DownloadController` in `lib/presentation/screens/downloads/downloads_screen.dart` to use `downloadServiceProvider`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Refresh Button Loading State (Priority: P1) 🎯 MVP

**Goal**: Add loading indicator to refresh button in PodcastDetailScreen. Button should be disabled during refresh and show CircularProgressIndicator.

**Independent Test**: Tap refresh button → button becomes disabled and shows spinner → refresh completes → button returns to normal.

### Implementation for User Story 1

- [ ] T006 [US1] Update `PodcastDetailScreen` in `lib/presentation/screens/podcast_detail/podcast_detail_screen.dart`
  - Watch `episodesProvider(podcastId)` to get loading state
  - Disable refresh button when `episodesState.isLoading == true`
  - Show `CircularProgressIndicator` in place of refresh icon during loading
  - Pass `context` to `_refreshEpisodes` for SnackBar display

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently.

---

## Phase 4: User Story 2 - Settings Screen Riverpod Migration (Priority: P2)

**Goal**: Convert SettingsScreen from ConsumerStatefulWidget to ConsumerWidget, eliminating all setState calls.

**Independent Test**: Settings screen loads and works without setState; `grep -r "setState" lib/presentation/screens/settings_screen.dart` returns 0.

### Implementation for User Story 2

- [ ] T007 [US2] Update `SettingsScreen` in `lib/presentation/screens/settings/settings_screen.dart`
  - Replace `ConsumerStatefulWidget` with `ConsumerWidget`
  - Remove `_prefs`, `_isLoading`, `_error`, `_updateVersion` state fields
  - Use `ref.watch(userPreferenceProvider)` for state management
  - Handle loading/error/data states with `AsyncValue.when()`
  - Remove all `setState` calls
  - Remove `_loadPreferences()` method (provider handles loading)
  - Remove `_updatePreference()` method (use provider directly)
  - Fix `RadioListTile` deprecation in dialogs

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently.

---

## Phase 5: User Story 3 - Repository Pattern Cleanup (Priority: P3)

**Goal**: Fix `prefer_initializing_formals` lint in repository files and use `query.watch()` for reactive streams.

**Independent Test**: `flutter analyze` shows 0 `prefer_initializing_formals` warnings.

### Implementation for User Story 3

- [ ] T008 [P] [US3] Fix `prefer_initializing_formals` in `lib/data/repositories/podcast_repository.dart`
  - Change `PodcastRepository({RssFeedParser? rssParser, required AppDatabase database})` to use `this._rssParser`
  - Replace `Stream.fromFuture(query.get())` with `query.watch()` for `subscribedPodcasts`

- [ ] T009 [P] [US3] Fix `prefer_initializing_formals` in `lib/data/repositories/episode_repository.dart`
  - Change `EpisodeRepository({RssFeedParser? rssParser, required AppDatabase database})` to use `this._rssParser`
  - Replace `Stream.fromFuture(query.get())` with `query.watch()` for `getDownloadedEpisodes()` and `getNewEpisodes()`

- [ ] T010 [P] [US3] Fix `prefer_initializing_formals` in `lib/data/repositories/bookmark_repository.dart`
  - Change `BookmarkRepository({required AppDatabase database})` to use `this._database`

- [ ] T011 [P] [US3] Fix `prefer_initializing_formals` in `lib/data/repositories/user_preference_repository.dart`
  - Change `UserPreferenceRepository({required AppDatabase database})` to use `this._database`

**Checkpoint**: All repository files use `this._field` initializing formals and reactive streams.

---

## Phase 6: User Story 4 - DownloadService Provider Injection (Priority: P3)

**Goal**: Inject DownloadService via provider for testability.

**Independent Test**: DownloadService can be overridden with mock in tests via `ProviderScope(overrides: [...])`.

### Implementation for User Story 4

- [ ] T012 [US4] Update `DownloadController` in `lib/presentation/screens/downloads/downloads_screen.dart`
  - Use `downloadServiceProvider` from provider instead of direct `DownloadService()` instantiation

**Checkpoint**: DownloadService is fully injected via Riverpod.

---

## Phase 7: User Story 5 - Deprecated API Migration (Priority: P3)

**Goal**: Migrate RadioListTile to RadioGroup in settings_screen.dart.

**Independent Test**: `flutter analyze` shows 0 `deprecated_member_use` warnings.

### Implementation for User Story 5

- [ ] T013 [US5] Update `SettingsScreen` in `lib/presentation/screens/settings/settings_screen.dart`
  - Replace `RadioListTile` with `RadioGroup` ancestor + `Radio` widgets in all dialogs
  - Remove `groupValue`/`onChanged` parameters

**Checkpoint**: No deprecated RadioListTile usage remains.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T014 [P] Verify all unit tests pass (`flutter test`)
- [ ] T015 [P] Verify `flutter analyze` returns zero errors and zero warnings
- [ ] T016 Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3 → P3 → P3)
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2)
- **User Story 2 (P2)**: Can start after Foundational (Phase 2)
- **User Story 3 (P3)**: Can start after Foundational (Phase 2)
- **User Story 4 (P3)**: Depends on Phase 2 (downloadServiceProvider)
- **User Story 5 (P3)**: Should run after US2 (Settings screen)

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- US3 tasks (T008-T011) can run in parallel (different files)
- All tests for a user story marked [P] can run in parallel

---

## Parallel Example: User Story 3

```bash
# Launch all repository fixes in parallel:
Task: "Fix prefer_initializing_formals in podcast_repository.dart"
Task: "Fix prefer_initializing_formals in episode_repository.dart"
Task: "Fix prefer_initializing_formals in bookmark_repository.dart"
Task: "Fix prefer_initializing_formals in user_preference_repository.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Stories 3-5 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
