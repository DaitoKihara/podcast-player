import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../domain/entities/app_exception.dart';

/// iTunes Search API client for discovering podcasts.
class ITunesApiClient {
  ITunesApiClient() : _dio = createITunesDio();

  final Dio _dio;

  /// Searches for podcasts by keyword.
  Future<List<PodcastSearchResult>> searchPodcasts({
    required String term,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'term': term,
          'media': 'podcast',
          'limit': limit,
          'offset': offset,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      return results
          .map((json) => PodcastSearchResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // ignore: only_throw_errors
      throw AppException.network(
        message: 'Failed to search podcasts: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      // ignore: only_throw_errors
      throw AppException.network(
        message: 'Unexpected error during search',
        originalError: e,
      );
    }
  }

  /// Looks up a podcast by iTunes ID.
  Future<PodcastSearchResult?> getPodcastById(int itunesId) async {
    try {
      final response = await _dio.get(
        '/lookup',
        queryParameters: {
          'id': itunesId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      if (results.isEmpty) {
        return null;
      }

      return PodcastSearchResult.fromJson(results.first as Map<String, dynamic>);
    } on DioException catch (e) {
      // ignore: only_throw_errors
      throw AppException.network(
        message: 'Failed to lookup podcast: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      // ignore: only_throw_errors
      throw AppException.network(
        message: 'Unexpected error during lookup',
        originalError: e,
      );
    }
  }
}

/// Result from iTunes Search API search/lookup.
class PodcastSearchResult {
  const PodcastSearchResult({
    this.collectionId,
    this.collectionName,
    this.artistName,
    this.artworkUrl600,
    this.feedUrl,
    this.genres,
    this.trackCount,
  });

  final int? collectionId;
  final String? collectionName;
  final String? artistName;
  final String? artworkUrl600;
  final String? feedUrl;
  final List<String>? genres;
  final int? trackCount;

  factory PodcastSearchResult.fromJson(Map<String, dynamic> json) {
    return PodcastSearchResult(
      collectionId: json['collectionId'] as int?,
      collectionName: json['collectionName'] as String?,
      artistName: json['artistName'] as String?,
      artworkUrl600: json['artworkUrl600'] as String?,
      feedUrl: json['feedUrl'] as String?,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>(),
      trackCount: json['trackCount'] as int?,
    );
  }
}
