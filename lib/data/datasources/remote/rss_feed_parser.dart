import 'package:dio/dio.dart';
import 'package:rss_dart/dart_rss.dart';

import '../../../core/network/dio_client.dart';
import '../../../domain/entities/app_exception.dart';

/// RSS feed parser for fetching podcast episodes.
class RssFeedParser {
  RssFeedParser() : _dio = createGeneralDio();

  final Dio _dio;

  /// Parses a podcast RSS feed and returns episode information.
  Future<RssFeedResult> parseFeed(String rssUrl) async {
    try {
      final response = await _dio.get(rssUrl);
      final feed = RssFeed.parse(response.data as String);

      return RssFeedResult(
        podcastInfo: PodcastInfo(
          title: feed.title ?? '',
          description: feed.description ?? '',
          imageUrl: feed.image?.url ?? '',
        ),
        episodes: feed.items
            .where((item) => item.enclosure?.url != null)
            .map((item) => EpisodeInfo(
                  title: item.title ?? '',
                  description: item.description ?? '',
                  audioUrl: item.enclosure!.url!,
                  duration: item.itunes?.duration?.inSeconds,
                  publishDate:
                      DateTime.tryParse(item.pubDate ?? '') ?? DateTime.now(),
                  guid: item.guid ?? item.link ?? item.enclosure!.url!,
                ))
            .toList(),
      );
    } on DioException catch (e) {
      throw AppException.network(
        message: 'Failed to fetch RSS feed: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw AppException.feedParse(
        message: 'Failed to parse RSS feed',
        originalError: e,
      );
    }
  }
}

/// Result from parsing an RSS feed.
class RssFeedResult {
  const RssFeedResult({
    required this.podcastInfo,
    required this.episodes,
  });

  final PodcastInfo podcastInfo;
  final List<EpisodeInfo> episodes;
}

/// Podcast information from RSS feed.
class PodcastInfo {
  const PodcastInfo({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String imageUrl;
}

/// Episode information from RSS feed.
class EpisodeInfo {
  const EpisodeInfo({
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.publishDate,
    required this.guid,
    this.duration,
  });

  final String title;
  final String description;
  final String audioUrl;
  final int? duration;
  final DateTime publishDate;
  final String guid;
}
