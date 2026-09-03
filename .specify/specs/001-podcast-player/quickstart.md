# Quickstart Guide — Podcast Player App

**Date**: 2026-09-03

## Prerequisites

- **Flutter SDK**: 3.47.2+ (with Dart 3.13+)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Chrome** or **Edge** (for Web development)
- **Git**

## Installation

### 1. Flutter SDK Setup

```bash
# macOS/Linux
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git
export PATH="$PATH:/path/to/flutter/bin"
flutter doctor

# Verify
flutter --version
```

### 2. Clone Repository

```bash
git clone https://github.com/DaitoKihara/podcast-player.git
cd podcast-player
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Code Generation (freezed + Isar)

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Or watch for changes during development
dart run build_runner watch
```

### 5. Configure Android

The project includes `just_audio_background` setup. Ensure your `android/app/src/main/AndroidManifest.xml` has the required permissions:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
```

## Running the App

### Android (Emulator or Device)

```bash
# List available devices
flutter devices

# Run on emulator/device
flutter run -d <device-id>
```

### Web (Chrome)

```bash
flutter run -d chrome
```

### Web (Release Build)

```bash
flutter build web --release
# Output: build/web/
```

## Project Structure Overview

```
lib/
├── main.dart              # App entry point
├── app.dart               # MaterialApp + Riverpod setup
├── router/                # go_router configuration
├── core/                  # Shared utilities
├── data/                  # Data layer
│   ├── datasources/       # Local (Isar) + Remote (API/RSS)
│   ├── models/            # Isar collection models
│   └── repositories/      # Repository implementations
├── domain/                # Business logic
│   ├── entities/          # Freezed value objects
│   ├── repositories/      # Abstract interfaces
│   └── usecases/          # Single-responsibility actions
├── presentation/          # UI layer
│   ├── providers/         # Riverpod state management
│   ├── screens/           # Full-page views
│   └── widgets/           # Reusable components
└── services/              # Platform services
```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Run Tests

```bash
# Unit + widget tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 3. Linting

```bash
# Uses analysis_options.yaml with strict rules
flutter analyze
```

### 4. Code Generation

```bash
# After modifying freezed models or Isar collections
dart run build_runner build --delete-conflicting-outputs
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Declarative routing |
| `freezed` + `json_serializable` | Immutable models |
| `isar` + `isar_flutter_libs` | Local database |
| `just_audio` | Audio playback |
| `just_audio_background` | Background playback + notification |
| `dio` | HTTP client |
| `rss_dart` | RSS feed parsing |
| `cached_network_image` | Image caching |
| `flutter_hooks` | Stateful widget logic |
| `flutter_secure_storage` | Secure token storage |

## Architecture Rules

1. **Separation of Concerns**: UI → Providers → UseCases → Repositories → DataSources
2. **Immutability**: All domain entities use `freezed`; state is never mutated directly
3. **Testability**: Every layer can be mocked via abstract interfaces
4. **Error Handling**: Typed exceptions (`AppException` subtypes) with user-friendly messages
5. **Test-First**: Write tests BEFORE implementing features (Constitution II)

## Common Issues

### Code Generation Fails
```bash
# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Just Audio Background Not Working
- Check AndroidManifest.xml permissions
- Ensure notification channel is configured
- Verify `JustAudioBackground.init()` is called before `runApp()`

### Web CORS Issues
- iTunes API: Already CORS-enabled (no action needed)
- Audio streaming: May require proxy for some feeds
- Workaround: Download audio before playback

## Next Steps

1. Complete Phase 2: Task breakdown (`/speckit-tasks`)
2. Implement P1 user stories first
3. Set up CI/CD (GitHub Actions)
