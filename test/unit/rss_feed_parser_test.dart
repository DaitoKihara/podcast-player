import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/remote/rss_feed_parser.dart';

class _TestDio implements Dio {
  _TestDio(this._response);

  final dynamic _response;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return Response<T>(
      data: _response as T,
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RssFeedParser', () {
    test('parseFeed parses RSS XML correctly', () async {
      const rssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Test Podcast</title>
    <description>A test podcast</description>
    <image>
      <url>https://example.com/image.jpg</url>
    </image>
    <item>
      <title>Episode 1</title>
      <description>First episode</description>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg" length="12345"/>
      <pubDate>Wed, 15 Sep 2026 12:00:00 GMT</pubDate>
      <guid>episode-1</guid>
    </item>
  </channel>
</rss>''';

      final parser = RssFeedParser(dio: _TestDio(rssXml));
      final result = await parser.parseFeed('https://example.com/feed');

      expect(result.podcastInfo.title, equals('Test Podcast'));
      expect(result.episodes.length, equals(1));
      expect(result.episodes[0].title, equals('Episode 1'));
    });

    test('parseFeed filters items without enclosure', () async {
      const rssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Test Podcast</title>
    <description>A test podcast</description>
    <item>
      <title>Episode Without Audio</title>
      <description>No audio file</description>
    </item>
    <item>
      <title>Episode With Audio</title>
      <description>Has audio</description>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg"/>
    </item>
  </channel>
</rss>''';

      final parser = RssFeedParser(dio: _TestDio(rssXml));
      final result = await parser.parseFeed('https://example.com/feed');

      expect(result.episodes.length, equals(1));
      expect(result.episodes[0].title, equals('Episode With Audio'));
    });

    test('parseFeed handles empty RSS feed', () async {
      const rssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Empty Podcast</title>
    <description>No episodes</description>
  </channel>
</rss>''';

      final parser = RssFeedParser(dio: _TestDio(rssXml));
      final result = await parser.parseFeed('https://example.com/feed');

      expect(result.podcastInfo.title, equals('Empty Podcast'));
      expect(result.episodes, isEmpty);
    });

    test('parseFeed handles multiple episodes', () async {
      const rssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Multi Episode Podcast</title>
    <item>
      <title>Episode 1</title>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg"/>
      <guid>ep-1</guid>
    </item>
    <item>
      <title>Episode 2</title>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg"/>
      <guid>ep-2</guid>
    </item>
    <item>
      <title>Episode 3</title>
      <enclosure url="https://example.com/ep3.mp3" type="audio/mpeg"/>
      <guid>ep-3</guid>
    </item>
  </channel>
</rss>''';

      final parser = RssFeedParser(dio: _TestDio(rssXml));
      final result = await parser.parseFeed('https://example.com/feed');

      expect(result.episodes.length, equals(3));
      expect(result.episodes[0].title, equals('Episode 1'));
      expect(result.episodes[1].title, equals('Episode 2'));
      expect(result.episodes[2].title, equals('Episode 3'));
    });

    test('parseFeed handles missing fields gracefully', () async {
      const rssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <item>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg"/>
    </item>
  </channel>
</rss>''';

      final parser = RssFeedParser(dio: _TestDio(rssXml));
      final result = await parser.parseFeed('https://example.com/feed');

      expect(result.episodes.length, equals(1));
      expect(result.episodes[0].title, equals(''));
      expect(result.podcastInfo.title, equals(''));
    });

    test('RssFeedResult can be constructed', () {
      final result = RssFeedResult(
        podcastInfo: const PodcastInfo(
          title: 'Test',
          description: 'Test desc',
          imageUrl: 'https://example.com/image.jpg',
        ),
        episodes: [
          EpisodeInfo(
            title: 'Ep 1',
            description: 'Episode 1',
            audioUrl: 'https://example.com/ep1.mp3',
            publishDate: DateTime.now(),
            guid: 'ep-1',
          ),
        ],
      );

      expect(result.podcastInfo.title, equals('Test'));
      expect(result.episodes.length, equals(1));
    });

    test('PodcastInfo can be constructed', () {
      const info = PodcastInfo(
        title: 'Test',
        description: 'Test description',
        imageUrl: 'https://example.com/img.jpg',
      );

      expect(info.title, equals('Test'));
      expect(info.description, equals('Test description'));
      expect(info.imageUrl, equals('https://example.com/img.jpg'));
    });

    test('EpisodeInfo can be constructed with duration', () {
      final info = EpisodeInfo(
        title: 'Test Episode',
        description: 'Description',
        audioUrl: 'https://example.com/ep.mp3',
        duration: 3600,
        publishDate: DateTime.now(),
        guid: 'test-guid',
      );

      expect(info.title, equals('Test Episode'));
      expect(info.duration, equals(3600));
      expect(info.guid, equals('test-guid'));
    });

    test('EpisodeInfo can be constructed without duration', () {
      final info = EpisodeInfo(
        title: 'Test Episode',
        description: 'Description',
        audioUrl: 'https://example.com/ep.mp3',
        publishDate: DateTime.now(),
        guid: 'test-guid',
      );

      expect(info.title, equals('Test Episode'));
      expect(info.duration, isNull);
    });
  });
}
