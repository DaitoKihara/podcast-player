import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/remote/itunes_api_client.dart';

void main() {
  group('ITunesApiClient', () {
    late ITunesApiClient client;

    setUp(() {
      client = ITunesApiClient();
    });

    test('searchPodcasts returns list of results', () async {
      final results = await client.searchPodcasts(
        term: 'tech',
        limit: 10,
        offset: 0,
      );

      expect(results, isA<List>());
      if (results.isNotEmpty) {
        final first = results.first;
        expect(first.collectionName, isA<String>());
        expect(first.artistName, isA<String>());
      }
    });

    test('getPodcastById returns null for invalid ID', () async {
      final result = await client.getPodcastById(0);
      expect(result, isNull);
    });
  });
}
