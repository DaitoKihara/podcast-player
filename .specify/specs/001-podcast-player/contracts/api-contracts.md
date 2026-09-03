# Phase 1: API Contracts

**Date**: 2026-09-03

## iTunes Search API Client

### Interface
```dart
abstract class ITunesApiClient {
  Future<List<Podcast>> searchPodcasts(PodcastSearchQuery query);
  Future<Podcast?> getPodcastById(int itunesId);
  Future<List<Podcast>> getTopPodcasts({String? category, int limit = 50});
}
```

### Implementation
```dart
class ITunesApiImpl implements ITunesApiClient {
  final Dio _dio;
  static const String _baseUrl = 'https://itunes.apple.com';
  
  @override
  Future<List<Podcast>> searchPodcasts(PodcastSearchQuery query) async {
    final response = await _dio.get(
      '$_baseUrl/search',
      queryParameters: {
        'term': query.term,
        'media': 'podcast',
        'limit': query.limit,
        'offset': query.offset,
        if (query.category != null) 'genreId': query.category,
      },
    );
    // Parse JSON → Podcast list
  }
}
```

### Error Handling
- `DioException` → `ApiException`
- 429 Too Many Requests → Retry with exponential backoff
- Timeout → `NetworkException`

---

## RSS Feed Parser

### Interface
```dart
abstract class RssFeedParser {
  Future<List<Episode>> parse(String rssUrl);
  Future<Podcast> parsePodcastInfo(String rssUrl);
}
```

### Implementation
```dart
class RssFeedParserImpl implements RssFeedParser {
  final Dio _dio;
  
  @override
  Future<List<Episode>> parse(String rssUrl) async {
    final response = await _dio.get(rssUrl);
    final feed = RssFeed.parse(response.data);
    
    return feed.items.map((item) => Episode(
      podcastId: 0, // Set by caller
      title: item.title ?? '',
      description: item.description ?? '',
      audioUrl: item.enclosure?.url ?? '',
      duration: _parseDuration(item.itunesDuration),
      publishDate: item.pubDate ?? DateTime.now(),
      guid: item.guid ?? item.link ?? '',
    )).toList();
  }
}
```

### Error Handling
- Invalid XML → `FeedParseException`
- Network error → `NetworkException`
- Missing fields → Use defaults

---

## Repository Interfaces

### PodcastRepository
```dart
abstract class PodcastRepository {
  Future<List<Podcast>> search(PodcastSearchQuery query);
  Stream<List<Podcast>> get subscribedPodcasts;
  Future<Podcast?> getById(int id);
  Future<void> subscribe(Podcast podcast);
  Future<void> unsubscribe(int podcastId);
  Future<void> update(Podcast podcast);
}
```

### EpisodeRepository
```dart
abstract class EpisodeRepository {
  Future<List<Episode>> getEpisodes(int podcastId);
  Stream<List<Episode>> getNewEpisodes(int podcastId);
  Future<void> markAsPlayed(int episodeId, int position);
  Future<void> toggleFavorite(int episodeId);
  Future<void> updatePosition(int episodeId, int position);
  Future<Episode?> getByGuid(String guid);
  Stream<List<Episode>> get downloadedEpisodes;
}
```

### SubscriptionRepository
```dart
abstract class SubscriptionRepository {
  Stream<List<Subscription>> getAll;
  Future<Subscription?> getByPodcastId(int podcastId);
  Future<void> updateSettings(int podcastId, {
    bool? autoDownload,
    bool? notificationsEnabled,
  });
}
```

### BookmarkRepository
```dart
abstract class BookmarkRepository {
  Future<void> add(Bookmark bookmark);
  Future<void> remove(int bookmarkId);
  Stream<List<Bookmark>> getBookmarks(int episodeId);
  Future<void> updateNote(int bookmarkId, String? note);
}
```

### UserPreferenceRepository
```dart
abstract class UserPreferenceRepository {
  Stream<UserPreference> get preference;
  Future<void> updateSkipForwardInterval(int seconds);
  Future<void> updateSkipBackwardInterval(int seconds);
  Future<void> updateDefaultPlaybackSpeed(double speed);
  Future<void> updateDownloadOnlyOnWifi(bool value);
  Future<void> updateAutoDownload(bool value);
  Future<void> updateDarkMode(bool value);
  Future<void> updateFontSize(double value);
  Future<void> updateSyncEnabled(bool value);
}
```

---

## Use Cases

### SearchPodcasts
```dart
class SearchPodcasts {
  final PodcastRepository _repository;
  
  Future<List<Podcast>> call(PodcastSearchQuery query) async {
    return _repository.search(query);
  }
}
```

### SubscribePodcast
```dart
class SubscribePodcast {
  final PodcastRepository _podcastRepo;
  final EpisodeRepository _episodeRepo;
  
  Future<void> call(Podcast podcast) async {
    await _podcastRepo.subscribe(podcast);
    // Fetch and cache first page of episodes
    final episodes = await _episodeRepo.getEpisodes(podcast.id!);
  }
}
```

### PlayEpisode
```dart
class PlayEpisode {
  final EpisodeRepository _episodeRepo;
  final AudioService _audioService;
  
  Future<void> call(int episodeId) async {
    final episode = await _episodeRepo.getById(episodeId);
    await _audioService.play(episode.audioUrl, episode.playedPosition);
  }
}
```

### DownloadEpisode
```dart
class DownloadEpisode {
  final EpisodeRepository _episodeRepo;
  final DownloadService _downloadService;
  
  Future<void> call(int episodeId) async {
    final episode = await _episodeRepo.getById(episodeId);
    final localPath = await _downloadService.download(episode.audioUrl);
    await _episodeRepo.updateLocalPath(episodeId, localPath);
  }
}
```

---

## Error Types

```dart
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
}

class NetworkException extends AppException { /* ... */ }
class ApiException extends AppException { /* ... */ }
class FeedParseException extends AppException { /* ... */ }
class StorageException extends AppException { /* ... */ }
class ValidationException extends AppException { /* ... */ }
```

---

## API Endpoints Summary

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/search?term=X&media=podcast` | GET | Search podcasts |
|/lookup?id=X` | GET | Get podcast by ID |
| RSS Feed URL | GET | Fetch episodes |

### Rate Limiting Strategy
- API Call Queue with 20 calls/min limit
- Exponential backoff on 429
- Cache results (TTL: 5 min for search, 1 hour for podcast info)
