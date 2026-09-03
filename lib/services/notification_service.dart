import 'package:flutter/foundation.dart';

/// Notification service for media playback controls on Android.
///
/// Manages notification channel setup and media control display
/// through the just_audio_background package.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  /// Android notification channel ID for audio playback.
  static const String channelId = 'com.daitokihara.podcast.channel.audio';

  /// Android notification channel name.
  static const String channelName = 'Podcast Playback';

  /// Whether the service has been initialized.
  bool _initialized = false;

  /// Whether the service is initialized.
  bool get isInitialized => _initialized;

  /// Initializes the notification service.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialization is handled by JustAudioBackground.init() in main.dart
    // This service provides a centralized place for notification-related
    // configuration and state management.
    _initialized = true;

    if (kDebugMode) {
      debugPrint('NotificationService initialized');
    }
  }

  /// Disposes of the notification service resources.
  Future<void> dispose() async {
    _initialized = false;
  }
}
