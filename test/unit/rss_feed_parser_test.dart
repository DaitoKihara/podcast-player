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
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  });
}
