# Phase 1: Data Model

**Date**: 2026-09-03

## Entities

### Podcast
```dart
@collection
class Podcast {
  Id id = Isar.autoIncrement;
  
  int? itunesId;                    // iTunes Search API ID
  String title;
  String author;
  String description;
  String artworkUrl;
  String rssUrl;
  String? category;
  int? episodeCount;
  DateTime subscribedAt;
  bool autoDownload;
  bool notificationsEnabled;
  
  // Isar indexes
  @Index(unique: true)
  int? itunesIdIndex;
  
  @Index()
  String titleIndex;
}
```

### Episode
```dart
@collection
class Episode {
  Id id = Isar.autoIncrement;
  
  int podcastId;                    // Podcast.id (Isar relation)
  String title;
  String description;
  String audioUrl;
  int? duration;                    // seconds
  DateTime publishDate;
  bool isPlayed;
  int playedPosition;               // seconds
  bool isFavorite;
  String? localPath;                // ダウンロード時のローカルパス
  String guid;                      // RSS GUID (一意制約用)
  
  @Index(unique: true)
  String guidIndex;
  
  @Index()
  int podcastIdIndex;
  
  @Index()
  DateTime publishDateIndex;
}
```

### Subscription
```dart
@collection
class Subscription {
  Id id = Isar.autoIncrement;
  
  int podcastId;                    // Podcast.id
  DateTime subscribedAt;
  bool autoDownload;
  bool notificationsEnabled;
  
  @Index(unique: true)
  int podcastIdIndex;
}
```

### Bookmark
```dart
@collection
class Bookmark {
  Id id = Isar.autoIncrement;
  
  int episodeId;                    // Episode.id
  int position;                     // seconds
  DateTime createdAt;
  String? note;
  
  @Index()
  int episodeIdIndex;
}
```

### UserPreference
```dart
@collection
class UserPreference {
  Id id = Isar.autoIncrement;
  
  int skipForwardInterval;          // default: 30
  int skipBackwardInterval;         // default: 10
  double defaultPlaybackSpeed;      // default: 1.0
  bool downloadOnlyOnWifi;          // default: true
  bool autoDownload;                // default: false
  bool darkMode;                    // default: false
  double fontSize;                  // default: 1.0
  bool syncEnabled;                 // default: false
  
  @Index()
  Id preferenceIndex;               // Always 0 (single record)
}
```

### DownloadRecord
```dart
enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
}

@collection
class DownloadRecord {
  Id id = Isar.autoIncrement;
  
  int episodeId;                    // Episode.id
  String localPath;
  DateTime downloadedAt;
  int fileSize;                     // bytes
  DownloadStatus status;
  
  @Index()
  int episodeIdIndex;
  
  @Index()
  DownloadStatus statusIndex;
}
```

## Value Objects (freezed)

```dart
@freezed
class PodcastSearchQuery with _$PodcastSearchQuery {
  const factory PodcastSearchQuery({
    required String term,
    @Default(50) int limit,
    @Default(0) int offset,
    String? category,
  }) = _PodcastSearchQuery;
}

@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    required int episodeId,
    required PlayerStatus status,
    required int position,
    required int duration,
    @Default(1.0) double speed,
  }) = _PlayerState;
}

enum PlayerStatus {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}
```

## Isar Relations

```dart
// Podcast → Episodes (one-to-many)
@collection
class Podcast {
  Id id = Isar.autoIncrement;
  // ... fields
  
  final episodes = IsarLinks<Episode>();
}

// Episode → Podcast (many-to-one)
@collection
class Episode {
  Id id = Isar.autoIncrement;
  // ... fields
  
  final podcast = IsarLink<Podcast>();
}
```
