# Podcast Player Constitution

## Core Principles

### I. Separation of Concerns
- **Presentation Layer (UI)**: Flutter widgets and screens — responsible for rendering
- **Business Logic Layer**: State management (Riverpod/Bloc) — handles app logic
- **Data Layer**: Repositories, data sources, local DB — manages data persistence and fetching
- Each module must be independently testable. UI components must be reusable.

### II. Test-First Development (NON-NEGOTIABLE)
- Write tests BEFORE implementing features
- Red → Green → Refactor cycle strictly enforced
- Unit tests for business logic, widget tests for UI, integration tests for critical paths
- Minimum coverage threshold: 80% for business logic

### III. User Experience First
- **Smooth playback**: Background audio, notification controls, lock screen controls
- **Intuitive controls**: Play, pause, skip, speed adjustment, sleep timer
- **Offline support**: Download episodes for offline listening
- **Accessibility**: Screen reader support, high contrast mode, scalable fonts

### IV. Cross-Platform Consistency
- Android and Web share design system and core logic
- Platform-specific features abstracted behind interfaces
- Responsive layouts that adapt to different screen sizes
- Single source of truth for business logic via Kotlin Multiplatform or Dart shared code

### V. Performance & Efficiency
- Prevent memory leaks with proper resource disposal
- Efficient list rendering for large podcast catalogs (Virtual scrolling)
- Optimize battery consumption (audio-only, background task management)
- Fast cold start (< 2 seconds on mid-range devices)

## Additional Constraints

### Technology Stack
- **Framework**: Flutter 3.47+ / Dart 3.13+
- **Target Platforms**: Android (minSdk 21), Web (responsive)
- **Audio Engine**: `just_audio` or `audioplayers` package
- **State Management**: Riverpod (preferred) or Bloc
- **Local Storage**: Isar (preferred) or Hive for offline cache
- **Networking**: `dio` + `rss_dart` for RSS feed parsing
- **API**: iTunes Search API for podcast discovery

### Security & Privacy
- No user data collection without explicit consent
- Secure token storage via `flutter_secure_storage`
- Network requests over HTTPS only

### Architecture Standards
- Use `freezed` for immutable data models
- Use `go_router` for declarative routing
- Use `flutter_hooks` for stateful widget logic where appropriate
- Follow Flutter official style guide and `analysis_options.yaml` linting

## Development Workflow

1. **Branch Strategy**: Feature branch workflow (`feature/episode-download`, `fix/playback-issue`)
2. **Code Review**: All PRs require at least one review before merge
3. **Testing Gate**: CI must pass (tests + linting) before merge is allowed
4. **Documentation**: Public APIs and complex logic must have inline documentation
5. **Constitution Compliance**: All PRs must verify alignment with this constitution

## Governance

- This constitution supersedes all other development practices
- Amendments require team discussion, documentation, and migration plan
- Version changes follow semantic versioning (MAJOR.MINOR.PATCH)
- Constitution is a living document — review quarterly

**Version**: 1.0.0 | **Ratified**: 2026-09-03 | **Last Amended**: 2026-09-03
