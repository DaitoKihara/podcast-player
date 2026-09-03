import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
sealed class AppException with _$AppException implements Exception {
  const factory AppException.network({
    @Default('Network error') String message,
    dynamic originalError,
  }) = NetworkException;

  const factory AppException.api({
    @Default('API error') String message,
    int? statusCode,
    dynamic originalError,
  }) = ApiException;

  const factory AppException.feedParse({
    @Default('Feed parse error') String message,
    dynamic originalError,
  }) = FeedParseException;

  const factory AppException.storage({
    @Default('Storage error') String message,
    dynamic originalError,
  }) = StorageException;

  const factory AppException.validation({
    @Default('Validation error') String message,
    dynamic originalError,
  }) = ValidationException;
}
