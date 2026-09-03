import 'package:freezed_annotation/freezed_annotation.dart';

part 'podcast_search_query.freezed.dart';

@freezed
sealed class PodcastSearchQuery with _$PodcastSearchQuery {
  const factory PodcastSearchQuery({
    required String term,
    @Default(50) int limit,
    @Default(0) int offset,
    String? category,
  }) = _PodcastSearchQuery;
}
