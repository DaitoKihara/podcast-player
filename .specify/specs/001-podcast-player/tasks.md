# Tasks: Podcast Player App

**Input**: Design documents from `/specs/001-podcast-player/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

---

## Format

- **[P]**: Can run in parallel (different files, no dependencies)
- **[US1-US6]**: Maps task to user story

## Path Conventions

- **Lib**: `lib/`
- **Tests**: `test/`
- **Integration Tests**: `integration_test/`
- **Android**: `android/`

---

## Phase 1: Setup

**Purpose**: Initialize project infrastructure

- [ ] T001 Create project structure per implementation plan
  - Create directories: `lib/{core,data,domain,presentation,services}`
  - Create directories: `lib/core/{constants,errors,network,utils}`
  - Create directories: `lib/data/{datasources,models,repositories}`
  - Create directories: `lib/data/datasources/{local,remote}`
  - Create directories: `lib/domain/{entities,repositories,usecases}`
  - Create directories: `lib/presentation/{providers,screens,widgets}`
  - Create directories: `test/{unit,integration,widget}`

- [ ] T002 Update `pubspec.yaml` with required dependencies
  - Add: `flutter_riverpod`, `go_router`, `freezed`, `json_serializable`
  - Add: `isar`, `isar_flutter_libs`
  - Add: `just_audio`, `just_audio_background`
  - Add: `dio`, `rss_dart`, `cached_network_image`
  - Add: `flutter_hooks`, `flutter_secure_storage`
  - Add: `build_runner`, `freezed_annotation`, `json_annotation`

- [ ] T003 [P] Configure linting and formatting
  - Update `analysis_options.yaml` with strict rules
  - Configure `dart_code_metrics` (optional)
  - Add `import_sorter` for import organization

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Setup Isar database
  - Configure `Isar` singleton with all schemas
  - Implement `IsarDatabase` wrapper class
  - Configure schemas: `Podcast`, `Episode`, `Subscription`, `Bookmark`, `UserPreference`, `DownloadRecord`
  - Setup database migration strategy

- [ ] T005 [P] Create base domain entities with freezed
  - Create `lib/domain/entities/player_state.dart` (freezed)
  - Create `lib/domain/entities/podcast_search_query.dart` (freezed)
  - Create `lib/domain/entities/download_status.dart` (freezed)
  - Create `lib/domain/entities/app_exception.dart` (freezed)

- [ ] T006 [P] Configure Riverpod providers structure
  - Setup `ProviderScope` in `main.dart`
  - Create `lib/presentation/providers/riverpod_setup.dart`
  - Configure global error handler provider

- [ ] T007 Setup network layer
  - Configure `Dio` client with base URL, interceptors, timeout
  - Implement `NetworkException` class
  - Configure retry logic for rate limits (iTunes API 20/min)

- [ ] T008 Setup Android background audio
  - Update `android/app/src/main/AndroidManifest.xml`
  - Add permissions: `WAKE_LOCK`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`
  - Configure `AudioServiceActivity` and `AudioService`
  - Initialize `JustAudioBackground` in `main.dart`

- [ ] T009 Setup router with go_router
  - Create `lib/router/app_router.dart`
  - Configure routes: `/`, `/search`, `/podcast/:id`, `/player`, `/downloads`, `/settings`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Podcast Discovery & Subscription (Priority: P1) 🎯 MVP

**Goal**: Search podcasts via iTunes API and subscribe to them

**Independent Test**: Search "Tech" podcasts, view results, subscribe to one, verify it appears in home screen

### Implementation for User Story 1

- [ ] T010 [P] [US1] Create `Podcast` Isar model
  - File: `lib/data/models/podcast.dart`
  - Fields: `id`, `itunesId`, `title`, `author`, `description`, `artworkUrl`, `rssUrl`, `category`, `subscribedAt`, `autoDownload`, `notificationsEnabled`

- [ ] T011 [P] [US1] Create `Subscription` Isar model
  - File: `lib/data/models/subscription.dart`
  - Fields: `id`, `podcastId`, `subscribedAt`, `autoDownload`, `notificationsEnabled`

- [ ] T012 [P] [US1] Create iTunes API client
  - File: `lib/data/datasources/remote/itunes_api_client.dart`
  - Implement: `searchPodcasts(PodcastSearchQuery)`
  - Implement: `getPodcastById(int itunesId)`
  - Implement: `getTopPodcasts({String? category, int limit})`
  - Error handling: `NetworkException`, rate limit retry

- [ ] T013 [P] [US1] Create RSS feed parser
  - File: `lib/data/datasources/remote/rss_feed_parser.dart`
  - Implement: `parsePodcastInfo(String rssUrl)` → `Podcast`
  - Implement: `parseEpisodes(String rssUrl, int podcastId)` → `List<Episode>`
  - Error handling: `FeedParseException` for invalid XML

- [ ] T014 [US1] Create `PodcastRepository` implementation
  - File: `lib/data/repositories/podcast_repository_impl.dart`
  - Dependencies: `ITunesApiClient`, `RssFeedParser`, `Isar`
  - Implement: `search()`, `getById()`, `subscribe()`, `unsubscribe()`, `update()`

- [ ] T015 [US1] Create `SearchPodcasts` use case
  - File: `lib/domain/usecases/search_podcasts.dart`
  - Dependencies: `PodcastRepository`
  - Returns: `Future<List<Podcast>>`

- [ ] T016 [US1] Create `SubscribePodcast` use case
  - File: `lib/domain/usecases/subscribe_podcast.dart`
  - Dependencies: `PodcastRepository`, `EpisodeRepository`
  - Side effect: Fetches and caches first page of episodes

- [ ] T017 [US1] Create `SearchScreen`
  - File: `lib/presentation/screens/search/search_screen.dart`
  - Features: Search bar, category chips, results grid/list
  - Widgets: `SearchBar`, `CategoryChip`, `PodcastCard`

- [ ] T018 [US1] Create `PodcastDetailScreen`
  - File: `lib/presentation/screens/podcast_detail/podcast_detail_screen.dart`
  - Features: Podcast info, subscribe/unsubscribe button, episode list
  - Widgets: `PodcastHeader`, `SubscribeButton`, `EpisodeList`

- [ ] T019 [US1] Create `HomeScreen` with subscriptions tab
  - File: `lib/presentation/screens/home/home_screen.dart`
  - Features: Bottom nav, "Subscriptions" tab shows subscribed podcasts sorted by update date
  - Widgets: `BottomNavBar`, `SubscriptionsTab`

**Checkpoint**: User Story 1 independently functional — can search and subscribe

---

## Phase 4: User Story 2 - Audio Playback (Priority: P1) 🎯 MVP

**Goal**: Play episodes with background, notification, and speed controls

**Independent Test**: Play an episode, verify mini-player appears, background playback continues, notification shows controls

### Implementation for User Story 2

- [ ] T020 [P] [US2] Create `Episode` Isar model
  - File: `lib/data/models/episode.dart`
  - Fields: `id`, `podcastId`, `title`, `description`, `audioUrl`, `duration`, `publishDate`, `isPlayed`, `playedPosition`, `isFavorite`, `localPath`, `guid`

- [ ] T021 [P] [US2] Create `AudioService` wrapper
  - File: `lib/services/audio_service.dart`
  - Dependencies: `just_audio`, `just_audio_background`
  - Features: `play()`, `pause()`, `stop()`, `seek()`, `setSpeed()`, `skipForward()`, `skipBackward()`
  - Expose: `Stream<PlayerState>`, `Stream<Duration>`

- [ ] T022 [P] [US2] Create `NotificationService`
  - File: `lib/services/notification_service.dart`
  - Features: Notification channel setup, media controls
  - Configure: `androidNotificationChannelId`, `androidNotificationChannelName`

- [ ] T023 [US2] Create `EpisodeRepository` implementation
  - File: `lib/data/repositories/episode_repository_impl.dart`
  - Dependencies: `RssFeedParser`, `Isar`
  - Implement: `getEpisodes()`, `markAsPlayed()`, `toggleFavorite()`, `updatePosition()`, `getByGuid()`

- [ ] T024 [US2] Create `PlayEpisode` use case
  - File: `lib/domain/usecases/play_episode.dart`
  - Dependencies: `EpisodeRepository`, `AudioService`
  - Side effect: Updates played position in DB

- [ ] T025 [US2] Create `MiniPlayer` widget
  - File: `lib/presentation/widgets/mini_player.dart`
  - Features: Episode title, progress bar, play/pause button
  - Tap to open full player

- [ ] T026 [US2] Create `PlayerScreen`
  - File: `lib/presentation/screens/player/player_screen.dart`
  - Features: Album art, seek bar, play/pause, skip, speed control, sleep timer button
  - Widgets: `PlayerControls`, `SeekBar`, `SpeedButton`

- [ ] T027 [US2] Wire up `PlayerProvider`
  - File: `lib/presentation/providers/player_provider.dart`
  - Features: `playerState` provider, `playEpisodeAction` provider, `seekAction` provider
  - Subscribes to `AudioService.playerStateStream`

**Checkpoint**: User Story 2 independently functional — can play audio with BG support

---

## Phase 5: User Story 3 - Episode Management (Priority: P2)

**Goal**: Mark as played, filter unread, favorite episodes

**Independent Test**: Play episode > 90%, verify auto-mark played; filter unread only; add favorite; verify badge on new episodes

### Implementation for User Story 3

- [ ] T028 [P] [US3] Create `toggleFavorite` method in `EpisodeRepository`
  - File: `lib/data/repositories/episode_repository_impl.dart` (add method)

- [ ] T029 [P] [US3] Create `markAsPlayed` method with 90% threshold logic
  - File: `lib/domain/usecases/mark_as_played.dart`

- [ ] T030 [P] [US3] Create `GetNewEpisodes` use case
  - File: `lib/domain/usecases/get_new_episodes.dart`

- [ ] T031 [US3] Create `EpisodeTile` widget with management actions
  - File: `lib/presentation/widgets/episode_tile.dart`
  - Features: Play indicator, favorite toggle, long-press menu (mark played/unplayed)
  - States: `isNew` (unplayed + recent), `isPlayed`, `isFavorite`

- [ ] T032 [US3] Add filter controls to `EpisodeList`
  - File: `lib/presentation/widgets/episode_list.dart`
  - Features: Filter chips (All, Unread, Favorites), sort options

- [ ] T033 [US3] Add new episode detection and badge
  - Detect new episodes on RSS refresh
  - Show `NEW` badge on `EpisodeTile`

---

## Phase 6: User Story 4 - Offline Download (Priority: P2)

**Goal**: Download episodes for offline playback with Wi-Fi only setting

**Independent Test**: Download episode on Wi-Fi, enable airplane mode, verify playback works; test mobile data blocking

### Implementation for User Story 4

- [ ] T034 [P] [US4] Create `DownloadRecord` Isar model
  - File: `lib/data/models/download_record.dart`
  - Fields: `id`, `episodeId`, `localPath`, `downloadedAt`, `fileSize`, `status`

- [ ] T035 [P] [US4] Create `DownloadService`
  - File: `lib/services/download_service.dart`
  - Dependencies: `dio`, `path_provider`
  - Features: `download(String url)`, `cancelDownload(int episodeId)`, `deleteDownload(int episodeId)`
  - Check Wi-Fi only setting before downloading

- [ ] T036 [US4] Create `UserPreference` Isar model and repository
  - File: `lib/data/models/user_preference.dart`
  - File: `lib/data/repositories/user_preference_repository_impl.dart`

- [ ] T037 [US4] Create `DownloadEpisode` use case
  - File: `lib/domain/usecases/download_episode.dart`
  - Dependencies: `EpisodeRepository`, `DownloadService`, `UserPreferenceRepository`
  - Validates Wi-Fi setting, storage capacity

- [ ] T038 [US4] Create `DownloadsScreen`
  - File: `lib/presentation/screens/downloads/downloads_screen.dart`
  - Features: Downloaded episodes tab, storage usage indicator

- [ ] T039 [US4] Add download controls to `EpisodeTile`
  - Download button, progress indicator, retry on failure

---

## Phase 7: User Story 5 - Sleep Timer & Bookmarks (Priority: P3)

**Goal**: Auto-stop playback after timer, bookmark specific timestamps

**Independent Test**: Set sleep timer for 15min, verify playback stops; add bookmark at 5:00, jump to it later

### Implementation for User Story 5

- [ ] T040 [P] [US5] Create `Bookmark` Isar model
  - File: `lib/data/models/bookmark.dart`
  - Fields: `id`, `episodeId`, `position`, `createdAt`, `note`

- [ ] T041 [P] [US5] Create `BookmarkRepository`
  - File: `lib/data/repositories/bookmark_repository_impl.dart`

- [ ] T042 [US5] Create `SleepTimerService`
  - File: `lib/services/sleep_timer_service.dart`
  - Features: `setTimer(Duration)`, `cancelTimer()`
  - On expiry: pause audio, show notification

- [ ] T043 [US5] Add sleep timer UI to `PlayerScreen`
  - Timer selector (5/10/15/30/60 min, end of episode)
  - Cancel timer button

- [ ] T044 [US5] Add bookmark functionality to `PlayerScreen`
  - Bookmark button, bookmarks list, jump to position

---

## Phase 8: User Story 6 - Cross-Platform Sync (Priority: P3)

**Goal**: Sync subscriptions and playback position across Android and Web

**Independent Test**: Subscribe on Android, verify on Web; play position syncs

### Implementation for User Story 6

- [ ] T045 [P] [US6] Design sync service architecture (v2)
  - File: `lib/services/sync_service.dart` (stub for v2)
  - Document: sync protocol, conflict resolution strategy

- [ ] T046 [P] [US6] Add auth placeholders
  - File: `lib/presentation/screens/auth/auth_screen.dart`
  - Placeholder for Google Sign-In

- [ ] T047 [US6] Add sync toggle in settings
  - File: `lib/presentation/screens/settings/settings_screen.dart`

---

## Phase 9: Settings & Polish

**Purpose**: Settings screen, accessibility, and final polish

- [ ] T048 [P] Create `SettingsScreen`
  - File: `lib/presentation/screens/settings/settings_screen.dart`
  - Sections: Playback (speed, skip intervals), Download (Wi-Fi only, auto), Appearance (dark mode, font size), Sync

- [ ] T049 [P] Add accessibility features
  - Screen reader labels on all controls
  - High contrast mode support
  - Scalable fonts via `MediaQuery`

- [ ] T050 [P] Run integration tests
  - File: `integration_test/app_test.dart`
  - Test: Search → Subscribe → Play → Download → Mark played flow

- [ ] T051 Update documentation
  - Update `README.md` with screenshots
  - Update `specs/001-podcast-player/quickstart.md` if needed

---

## Dependencies & Execution Order

### Phase Dependencies

1. **Phase 1 (Setup)**: No dependencies — start immediately
2. **Phase 2 (Foundational)**: Depends on Phase 1
3. **Phase 3 (US1)**: Depends on Phase 2
4. **Phase 4 (US2)**: Depends on Phase 2 — can run parallel with US1
5. **Phase 5 (US3)**: Depends on US2 — can run parallel with US4
6. **Phase 6 (US4)**: Depends on Phase 2 — can run parallel with US3
7. **Phase 7 (US5)**: Depends on US2
8. **Phase 8 (US6)**: Depends on Phase 2 — independent of others
9. **Phase 9 (Polish)**: Depends on all desired stories

### Parallel Opportunities

- Phase 1 tasks can all run in parallel
- Phase 2 tasks T005, T006, T007, T008, T009 can run in parallel
- US1, US2, US4 can run in parallel after Phase 2
- US3 and US5 can run in parallel after US2
- US6 can run in parallel with US3/US4/US5

### MVP First (US1 + US2 only)

1. Phase 1: Setup
2. Phase 2: Foundational
3. Phase 3: User Story 1
4. Phase 4: User Story 2
5. **STOP and VALIDATE**: Test MVP independently
6. Deploy/demo if ready

---

## Notes

- [P] tasks = different files, no dependencies
- [USX] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
