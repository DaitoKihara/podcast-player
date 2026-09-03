import 'package:flutter_test/flutter_test.dart';
import 'package:podcast_player/domain/usecases/mark_as_played.dart';

void main() {
  group('MarkAsPlayed', () {
    group('isThresholdMet', () {
      test('returns false when duration is 0', () {
        expect(
          MarkAsPlayed.isThresholdMet(
            positionSeconds: 100,
            durationSeconds: 0,
          ),
          isFalse,
        );
      });

      test('returns false when below 90% threshold', () {
        expect(
          MarkAsPlayed.isThresholdMet(
            positionSeconds: 89,
            durationSeconds: 100,
          ),
          isFalse,
        );
      });

      test('returns true when at exactly 90% threshold', () {
        expect(
          MarkAsPlayed.isThresholdMet(
            positionSeconds: 90,
            durationSeconds: 100,
          ),
          isTrue,
        );
      });

      test('returns true when above 90% threshold', () {
        expect(
          MarkAsPlayed.isThresholdMet(
            positionSeconds: 95,
            durationSeconds: 100,
          ),
          isTrue,
        );
      });

      test('returns true when at 100% duration', () {
        expect(
          MarkAsPlayed.isThresholdMet(
            positionSeconds: 100,
            durationSeconds: 100,
          ),
          isTrue,
        );
      });
    });
  });
}
