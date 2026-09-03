import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Download status enum
enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
}

/// Download service for managing episode downloads.
///
/// Features:
/// - Download episodes to local storage
/// - Wi-Fi only download setting
/// - Cancel and delete downloads
class DownloadService {
  DownloadService({
    Dio? dio,
    Connectivity? connectivity,
  })  : _dio = dio ?? Dio(),
        _connectivity = connectivity ?? Connectivity();

  final Dio _dio;
  final Connectivity _connectivity;

  /// Check if currently connected to Wi-Fi
  Future<bool> isWifiConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Download a file from URL to local storage
  ///
  /// [url] The download URL
  /// [episodeId] The episode ID for local file naming
  /// [onProgress] Optional progress callback (0.0 to 1.0)
  ///
  /// Returns the local file path of the downloaded file
  Future<String> download({
    required String url,
    required int episodeId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final filePath = '${downloadDir.path}/episode_$episodeId.mp3';

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return filePath;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw DownloadCancelledException();
      }
      throw DownloadException('Download failed: ${e.message}');
    } catch (e) {
      throw DownloadException('Download failed: $e');
    }
  }

  /// Cancel a download (placeholder - Dio doesn't support cancellation
  /// of in-progress downloads natively without CancelToken)
  void cancelDownload(int episodeId) {
    // Implementation would track CancelTokens per download
  }

  /// Delete a downloaded file
  Future<void> deleteDownload(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get the size of a downloaded file
  Future<int> getFileSize(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Get total storage used by downloads
  Future<int> getTotalStorageUsed() async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/downloads');
    if (!await downloadDir.exists()) {
      return 0;
    }

    int totalSize = 0;
    await for (final entity in downloadDir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }
}

/// Exception for download operations
class DownloadException implements Exception {
  final String message;
  DownloadException(this.message);

  @override
  String toString() => 'DownloadException: $message';
}

/// Exception for cancelled downloads
class DownloadCancelledException implements Exception {
  @override
  String toString() => 'DownloadCancelledException';
}
