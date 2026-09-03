# Implementation Plan: Podcast Player App

**Branch**: `feature/001-podcast-player` | **Date**: 2026-09-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-podcast-player/spec.md`

## Summary

Build a cross-platform podcast player app using Flutter targeting Android and Web. Core features include podcast discovery via iTunes Search API, RSS feed parsing, audio playback with background/offline support, episode management, sleep timer, and cross-platform sync. The app will follow a layered architecture (Presentation / Business Logic / Data) with Riverpod for state management and Isar for local storage.

## Technical Context

**Language/Version**: Dart 3.13+ (Flutter 3.47+)

**Primary Dependencies**:
- `just_audio` — audio playback engine
- `riverpod` — state management
- `isar` — local database
- `dio` — HTTP client
- `rss_dart` — RSS feed parsing
- `go_router` — declarative routing
- `freezed` — immutable data models
- `flutter_hooks` — stateful widget logic
- `flutter_secure_storage` — secure token storage

**Storage**: Isar (local database) for offline cache, episode metadata, user preferences. flutter_secure_storage for auth tokens.

**Testing**: `flutter_test` (unit/widget), `integration_test` (integration), custom coverage threshold 80%.

**Target Platform**: Android (minSdk 21), Web (responsive desktop + mobile browser).

**Project Type**: Mobile + Web application (Flutter).

**Performance Goals**:
- Cold start < 2 seconds
- Audio playback start < 500ms from tap
- Background playback without OS kill
- Battery consumption < 5% per hour of background playback

**Constraints**:
- No user data collection without explicit consent
- HTTPS only for network requests
- Memory leaks must be prevented (proper resource disposal)
- Efficient list rendering for large catalogs (virtual scrolling)

**Scale/Scope**:
- ~50 screens total
- 6 user stories (P1-P3 priority)
- 32 functional requirements
- 6 key data entities

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Separation of Concerns | ✅ Pass | 3-layer architecture: UI (widgets) / BL (Riverpod) / Data (Isar + API) |
| II. Test-First (NON-NEGOTIABLE) | ✅ Pass | TDD enforced: tests written before implementation, 80% coverage target |
| III. UX First | ✅ Pass | Background audio, notification controls, offline support, accessibility included |
| IV. Cross-Platform Consistency | ✅ Pass | Android + Web share design system and core logic via Flutter |
| V. Performance & Efficiency | ✅ Pass | Cold start <2s, memory leak prevention, virtual scrolling planned |

## Project Structure

### Documentation (this feature)

```text
specs/001-podcast-player/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
podcast-player/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   └── utils/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── isar_database.dart
│   │   │   │   └── podcast_local_datasource.dart
│   │   │   └── remote/
│   │   │       ├── itunes_api_client.dart
│   │   │       └── rss_feed_parser.dart
│   │   ├── models/
│   │   │   ├── podcast.dart
│   │   │   ├── episode.dart
│   │   │   ├── subscription.dart
│   │   │   ├── bookmark.dart
│   │   │   ├── user_preference.dart
│   │   │   └── download_record.dart
│   │   └── repositories/
│   │       ├── podcast_repository.dart
│   │       ├── episode_repository.dart
│   │       └── subscription_repository.dart
│   ├── domain/
│   │   ├── entities/                 # (freezed models)
│   │   ├── repositories/             # abstract interfaces
│   │   └── usecases/
│   │       ├── search_podcasts.dart
│   │       ├── subscribe_podcast.dart
│   │       ├── play_episode.dart
│   │       ├── toggle_favorite.dart
│   │       ├── download_episode.dart
│   │       └── sync_data.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── player_provider.dart
│   │   │   ├── subscription_provider.dart
│   │   │   └── settings_provider.dart
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   ├── search/
│   │   │   ├── podcast_detail/
│   │   │   ├── player/
│   │   │   ├── downloads/
│   │   │   ├── settings/
│   │   │   └── auth/
│   │   └── widgets/
│   │       ├── mini_player.dart
│   │       ├── episode_tile.dart
│   │       ├── podcast_card.dart
│   │       └── audio_controls.dart
│   └── services/
│       ├── audio_service.dart
│       ├── background_service.dart
│       ├── notification_service.dart
│       └── sync_service.dart
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── integration_test/
├── android/
├── web/
└── pubspec.yaml
```

**Structure Decision**: Single Flutter project with layered architecture. All code under `lib/` organized by layer (data/domain/presentation/services). This aligns with Constitution principle I (Separation of Concerns) and enables independent testability of each layer.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Layered Architecture (3 layers) | Required by Constitution I. Enables independent testing and modular development. | Single-file or 2-layer approach would violate separation of concerns, making unit testing difficult. |
| Isar (NoSQL DB) | Needed for fast local queries on large podcast catalogs and offline support. | Hive is simpler but lacks type safety and complex query support needed for filtering/sorting. |
| Riverpod + freezed | State management + immutability ensures predictable UI updates and testability. | setState or Provider alone would lead to unmanageable state in complex audio/download flows. |
| just_audio | Required for background playback, notification controls, speed change, and streaming. | audioplayers lacks background/notification support which is core to user story 2. |
| Background Service (foreground) | Required to prevent OS from killing playback process (Constitution V). | Simple background task would be killed by Android Doze/App Standby. |
| go_router | Declarative routing needed for deep links (shared episodes) and web URL support. | Navigator 1.0 imperative routing doesn't support web URLs or deep linking. |

---

## Phase 0: Research (Next Steps)

Research tasks to complete before implementation:

1. **iTunes Search API** — rate limits, response format, search parameters
2. **just_audio background configuration** — Android foreground service setup, notification channels
3. **Isar database** — schema design for offline episode caching, migration strategy
4. **RSS feed parsing** — common feed formats, error handling for malformed feeds
5. **Flutter Web audio** — browser compatibility, CORS issues with direct audio URLs
6. **Cross-platform sync** — Firebase or custom backend? Auth method?

## Phase 1: Design (After Research)

1. **Data Model** — freezed classes for all entities with Isar adapters
2. **API Contracts** — iTunes API client interface, RSS parser interface
3. **Repository Interfaces** — abstract classes for testability
4. **Quickstart** — setup guide for Flutter SDK, dependencies, running the app

## Phase 2: Implementation (After Design)

Will be generated by `/speckit-tasks` command based on user stories and priority.
