import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_player/data/datasources/local/app_database.dart';

/// Provider for the AppDatabase singleton.
///
/// Override in tests:
/// ```dart
/// ProviderScope(
///   overrides: [
///     appDatabaseProvider.overrideWithValue(mockDatabase),
///   ],
///   child: MyApp(),
/// )
/// ```
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});
