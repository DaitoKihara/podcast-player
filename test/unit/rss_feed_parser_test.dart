import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/remote/rss_feed_parser.dart';
import 'package:podcast_player/domain/entities/app_exception.dart';

void main() {
  group('RssFeedParser', () {
    late RssFeedParser parser;

    setUp(() {
      parser = RssFeedParser();
    });

    test('parseFeed returns RssFeedResult with podcast info and episodes', () async {
      final result = await parser.parseFeed(
        'https://feeds.simplecast.com/54nAGcIl',
      );

      expect(result.podcastInfo, isA<PodcastInfo>());
      expect(result.podcastInfo.title, isA<String>());
      expect(result.podcastInfo.description, isA<String>());
      expect(result.episodes, isA<List>());
    });

    test('parseFeed handles invalid URL gracefully', () async {
      expect(
        () => parser.parseFeed('https://invalid-url-that-does-not-exist.com/feed'),
        throwsA(isA<AppException>()),
      );
    });
  });
}
