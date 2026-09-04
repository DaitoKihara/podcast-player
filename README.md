# Podcast Player 🎧

A Flutter-based podcast player app with background playback, offline downloads, and cross-platform sync support.

## Features

### ✅ Implemented (v1.0)

- **Podcast Discovery**: Search podcasts via iTunes API
- **Subscriptions**: Subscribe to podcasts and manage your library
- **Audio Playback**: Full-featured player with background support
  - Play, pause, seek
  - Skip forward/backward (configurable intervals)
  - Playback speed control (0.5x - 3.0x)
  - Sleep timer (5/10/15/30/60 min)
- **Episode Management**: 
  - Auto-mark as played at 90% threshold
  - Favorite episodes
  - Bookmark specific timestamps
- **Offline Downloads**: 
  - Download episodes for offline listening
  - Wi-Fi only setting
  - Auto-download option
- **Settings**:
  - Skip interval configuration
  - Playback speed defaults
  - Wi-Fi only downloads
  - Auto-download
  - Dark mode toggle
  - Font size adjustment
  - Cross-device sync toggle (v2 placeholder)
- **Accessibility**: 
  - Screen reader labels on all controls
  - Semantic labels for navigation
  - Scalable fonts via MediaQuery

## Architecture

```
lib/
├── core/               # Utilities, network, constants
├── data/               # Data layer (datasources, models, repositories)
│   ├── datasources/
│   │   ├── local/      # Drift database
│   │   └── remote/     # iTunes API, RSS parser
│   ├── models/         # Drift table definitions
│   └── repositories/   # Repository implementations
├── domain/             # Business logic
│   ├── entities/       # Domain entities (freezed)
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Use cases
├── presentation/       # UI layer
│   ├── providers/      # Riverpod providers
│   ├── screens/        # Screen widgets
│   └── widgets/        # Reusable widgets
├── services/           # Audio, download, sync, sleep timer
└── router/             # GoRouter configuration
```

## Tech Stack

- **Framework**: Flutter 3.x with Dart 3.13+
- **State Management**: Riverpod
- **Routing**: GoRouter
- **Local DB**: Drift (SQLite)
- **Audio**: just_audio + just_audio_background
- **Network**: Dio
- **RSS Parsing**: rss_dart
- **JSON**: json_serializable + freezed

## Getting Started

### Prerequisites

- Flutter 3.13+ installed
- Dart 3.13+
- Android Studio / VS Code
- Android SDK (for Android builds)

### Installation

```bash
# Clone the repository
git clone https://github.com/DaitoKihara/podcast-player.git
cd podcast-player

# Get dependencies
flutter pub get

# Generate code (freezed, json_serializable, drift)
dart run build_runner build

# Run the app
flutter run
```

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/app_test.dart
```

## Development

### Code Generation

After modifying freezed models, drift tables, or json_serializable classes:

```bash
dart run build_runner build
```

### Linting

```bash
flutter analyze
```

## Project Status

This project uses **spec-driven development** with speckit. All specs and tasks are in `.specify/specs/001-podcast-player/`.

### Completed Phases

- ✅ Phase 1: Setup (project structure, dependencies)
- ✅ Phase 2: Foundational (DB, entities, network, router)
- ✅ Phase 3: User Story 1 - Podcast Discovery & Subscription
- ✅ Phase 4: User Story 2 - Audio Playback
- ✅ Phase 5: User Story 3 - Episode Management
- ✅ Phase 6: User Story 4 - Offline Download
- ✅ Phase 7: User Story 5 - Sleep Timer & Bookmarks
- ✅ Phase 8: User Story 6 - Cross-Platform Sync (stub)
- ✅ Phase 9: Settings & Polish

## License

MIT License
