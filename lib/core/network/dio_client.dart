import 'package:dio/dio.dart';

/// Base URL for iTunes Search API
const String iTunesApiBaseUrl = 'https://itunes.apple.com';

/// Creates a configured Dio client for iTunes API requests.
Dio createITunesDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: iTunesApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  // Add retry interceptor for rate limiting (429)
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        if (error.response?.statusCode == 429) {
          // Rate limited - could implement retry with backoff here
          // For now, let the error propagate
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}

/// Creates a configured Dio client for general requests (RSS feeds, etc.)
Dio createGeneralDio() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json, application/xml, text/xml, */*',
        'User-Agent': 'PodcastPlayer/1.0',
      },
    ),
  );

  return dio;
}
