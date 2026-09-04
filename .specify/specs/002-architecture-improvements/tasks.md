# Tasks: Architecture Improvements — State Management, Navigation & DI

**Input**: Design documents from `/specs/002-architecture-improvements/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: No tests explicitly requested — unit tests exist for repositories. Focus on refactoring to keep them green.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `lib/`, `test/` at repository root
- Paths shown below assume single project structure

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

- [x] T004 Create `appDatabaseProvider` in `lib/presentation/providers/database_provider.dart`
- [x] T005 [P] Create repository providers in `lib/presentation/providers/repository_providers.dart`
- [x] T006 [P] Create service providers in `lib/presentation/providers/service_providers.dart`
- [x] T007 Update `lib/presentation/providers/player_provider.dart` to use new providers
- [x] T008 Update `lib/presentation/screens/downloads/downloads_screen.dart` to use new providers

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Consistent State Management (Priority: P1) 🎯 MVP

**Goal**: Unify state management under Riverpod. Replace `StatefulWidget + setState` with `ConsumerWidget`. Eliminate `setState` calls from all screens.

**Independent Test**: `grep -r "setState" lib/` returns zero matches. All screens use `ConsumerWidget`. Existing unit tests still pass.

### Implementation for User Story 1

- [x] T009 [US1] Convert `HomeScreen` to `ConsumerWidget` in `lib/presentation/screens/home/home_screen.dart`
- [x] T010 [US1] Create `subscribedPodcastsProvider` in `lib/presentation/providers/podcast_providers.dart`
- [x] T011 [US1] Convert `SearchScreen` to `ConsumerWidget` in `lib/presentation/screens/search/search_screen.dart`
- [x] T012 [US1] Create `searchPodcastsProvider` in `lib/presentation/providers/podcast_providers.dart`
- [x] T013 [US1] Convert `PodcastDetailScreen` to `ConsumerWidget` in `lib/presentation/screens/podcast_detail/podcast_detail_screen.dart`
- [x] T014 [US1] Create `podcastProvider` in `lib/presentation/providers/podcast_providers.dart`
- [x] T015 [US1] Verify all `setState` calls removed

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently. All screens use Riverpod.

---

## Phase 4: User Story 2 - Working Navigation (Priority: P1) 🎯 MVP

**Goal**: Implement working navigation using `go_router`. All screen transitions functional. Users can navigate between Home, Search, PodcastDetail, Player, Downloads, and Settings screens.

**Independent Test**: Tap navigation works on all screens. `context.push('/podcast/$id')` navigates to detail. `context.push('/player')` opens player. `context.push('/downloads')` opens downloads. Back button works correctly.

### Implementation for User Story 2

- [x] T016 [US2] Implement HomeScreen navigation in `lib/presentation/screens/home/home_screen.dart`
- [x] T017 [US2] Implement SearchScreen navigation in `lib/presentation/screens/search/search_screen.dart`
- [x] T018 [US2] Implement PodcastDetailScreen episode tap in `lib/presentation/screens/podcast_detail/podcast_detail_screen.dart`
- [x] T019 [US2] Implement MiniPlayer navigation in `lib/presentation/widgets/mini_player.dart`
- [x] T020 [US2] Add AppBar navigation to HomeScreen in `lib/presentation/screens/home/home_screen.dart`
- [x] T21 [US2] Add AppBar navigation to SearchScreen in `lib/presentation/screens/search/search_screen.dart`
- [x] T022 [US2] Verify navigation works end-to-end

**Checkpoint**: At this point, User Story 2 should be fully functional. All navigation paths work correctly.

---

## Phase 5: User Story 3 - Dependency Injection via Riverpod (Priority: P1) 🎯 MVP

**Goal**: Inject all dependencies through Riverpod providers. Eliminate direct `AppDatabase.instance` references. All repositories and services obtained via `ref.watch()`. Tests can override providers with mocks.

**Independent Test**: `grep -r "AppDatabase.instance" lib/` returns zero matches. Unit tests pass with provider overrides. Mock injection works in tests.

### Implementation for User Story 3

- [x] T023 [US3] Create `databaseProvider` in `lib/presentation/providers/database_provider.dart`
- [x] T024 [US3] Create `repositoryProviders` in `lib/presentation/providers/repository_providers.dart`
- [x] T025 [US3] Create `serviceProviders` in `lib/presentation/providers/service_providers.dart`
- [x] T026 [US3] Remove direct `AppDatabase.instance` references from repositories
- [x] T027 [US3] Verify zero direct `AppDatabase.instance` references

**Checkpoint**: At this point, User Story 3 should be fully functional. All dependencies injected via Riverpod.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T028 [P] Update `lib/main.dart` to use new providers if needed
- [ ] T029 [P] Verify all unit tests pass (`flutter test`)
- [ ] T030 [P] Verify `flutter analyze` returns zero errors
- [ ] T031 Run quickstart.md validation (`bash .specify/specs/002-architecture-improvements/quickstart.md`)
- [ ] T032 Code cleanup and remove unused imports
- [ ] T033 Update existing unit tests to use provider overrides where needed

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P1 → P1)
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P1)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Convert HomeScreen to ConsumerWidget in lib/presentation/screens/home/home_screen.dart"
Task: "Create subscribedPodcastsProvider in lib/presentation/providers/podcast_providers.dart"
Task: "Convert SearchScreen to ConsumerWidget in lib/presentation/screens/search/search_screen.dart"
Task: "Create searchPodcastsProvider in lib/presentation/providers/podcast_providers.dart"
Task: "Convert PodcastDetailScreen to ConsumerWidget in lib/presentation/screens/podcast_detail/podcast_detail_screen.dart"
Task: "Create podcastProvider in lib/presentation/providers/podcast_providers.dart"
```
1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
