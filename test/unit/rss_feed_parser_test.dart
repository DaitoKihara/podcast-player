import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/remote/rss_feed_parser.dart';
import 'package:podcast_player/domain/entities/app_exception.dart';

void main() {
  group('RssFeedParser', () {
    late RssFeedParser parser;

    setUp(() {
      parser = RssFeedParser();
    });

    test('parseFeed throws for invalid URL', () async {
      expect(
        () => parser.parseFeed('https://invalid-url-that-does-not-exist.com/feed'),
        throwsA(isA<AppException>()),
      );
    });
  });
}
