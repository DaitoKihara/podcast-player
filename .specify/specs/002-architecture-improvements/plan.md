# Implementation Plan: Architecture Improvements — State Management, Navigation & DI

**Branch**: `002-architecture-improvements` | **Date**: 2026-09-04** | **Spec**: [spec.md](spec.md)

## Summary

Refactor the podcast-player codebase to achieve three architectural goals: (1) unify state management under Riverpod by replacing `StatefulWidget + setState` patterns, (2) implement working navigation using `go_router` for all screen transitions, and (3) inject all dependencies through Riverpod providers to enable test mocking.

## Technical Context

**Language/Version**: Dart 3.13.2+ / Flutter 3.47+

**Primary Dependencies**:
- `flutter_riverpod: ^2.6.1` — state management & DI
- `go_router: ^15.1.2` — declarative navigation
- `drift: ^2.27.0` — local database
- `freezed: ^3.0.6` — immutable data models

**Storage**: Drift (SQLite) — local database

**Testing**: `flutter_test` (unit + widget), `integration_test` (E2E)

**Target Platform**: Android (minSdk 21), Web (responsive)

**Project Type**: Mobile app (Flutter)

**Performance Goals**:
- Cold start < 2 seconds
- Tab-to-playback start < 500ms

**Constraints**:
- Refactoring only — no new features or API changes
- Must not break existing unit tests

**Scale/Scope**: 6 screens (Home, Search, PodcastDetail, Player, Downloads, Settings), 4 repositories, 4 services

## Constitution Check

| Gate | Status | Notes |
|------|--------|-------|
| Separation of Concerns | ✅ Pass | UI → State → Repository → DataSource layers already exist |
| Test-First Development | ✅ Pass | Existing unit tests cover repositories & use cases |
| User Experience First | ✅ Pass | Navigation improvements directly benefit UX |
| Cross-Platform Consistency | ✅ Pass | Android + Web architecture shared via Flutter |
| Performance & Efficiency | ✅ Pass | No new performance regressions introduced |

No violations. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/002-architecture-improvements/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── router/
│   └── app_router.dart
├── core/
│   ├── utils/
│   │   └── duration_formatter.dart
│   └── network/
│       └── dio_client.dart
├── domain/
│   ├── entities/
│   │   ├── player_state.dart
│   │   ├── app_exception.dart
│   │   └── podcast_search_query.dart
│   └── usecases/
│       ├── download_episode.dart
│       ├── mark_as_played.dart
│       ├── get_new_episodes.dart
│       └── play_episode.dart
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── app_database.dart
│   │   └── remote/
│   │       ├── rss_feed_parser.dart
│   │       └── itunes_api_client.dart
│   └── repositories/
│       ├── podcast_repository.dart
│       ├── episode_repository.dart
│       ├── bookmark_repository.dart
│       └── user_preference_repository.dart
├── services/
│   ├── audio_service.dart
│   ├── download_service.dart
│   ├── sync_service.dart
│   ├── sleep_timer_service.dart
│   └── notification_service.dart
└── presentation/
    ├── providers/
    │   └── player_provider.dart
    ├── screens/
    │   ├── home/
    │   ├── search/
    │   ├── podcast_detail/
    │   ├── player/
    │   ├── downloads/
    │   ├── settings/
    │   └── auth/
    └── widgets/
        ├── episode_tile.dart
        ├── episode_list.dart
        └── mini_player.dart
```

**Structure Decision**: Existing 3-layer architecture (Presentation → Domain → Data) is sound. Refactoring targets internal consistency, not structural reorganization.

## Complexity Tracking

No constitution violations to justify.
