import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/data/datasources/remote/itunes_api_client.dart';

void main() {
  group('ITunesApiClient', () {
    late ITunesApiClient client;

    setUp(() {
      client = ITunesApiClient();
    });

    test('searchPodcasts returns list of results', () async {
      // Note: This test requires network access
      // In a real project, you'd mock the Dio client
      final results = await client.searchPodcasts(
        term: 'tech',
        limit: 10,
        offset: 0,
      );

      expect(results, isA<List>());
      // If the API returns results, verify the structure
      if (results.isNotEmpty) {
        final first = results.first;
        expect(first.title, isA<String>());
        expect(first.author, isA<String>());
      }
    });

    test('getPodcastById returns null for invalid ID', () async {
      final result = await client.getPodcastById(0);
      expect(result, isNull);
    });
  });
}
