import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/remote/rss_feed_parser.dart';

void main() {
  group('RssFeedParser', () {
    late RssFeedParser parser;

    setUp(() {
      parser = RssFeedParser();
    });

    test('parseFeed handles invalid URL gracefully', () async {
      expect(
        () => parser.parseFeed('https://invalid-url-that-does-not-exist.com/feed'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
