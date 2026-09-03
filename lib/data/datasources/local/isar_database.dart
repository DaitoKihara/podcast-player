import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// Manages the Isar database instance.
class IsarDatabase {
  IsarDatabase._();

  static final IsarDatabase instance = IsarDatabase._();

  Isar? _isar;

  /// The Isar database instance.
  Isar get isar {
    if (_isar == null) {
      throw StateError(
        'IsarDatabase.initialize() must be called before accessing isar',
      );
    }
    return _isar!;
  }

  /// Initializes the Isar database.
  Future<Isar> initialize() async {
    if (_isar != null) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      IsarDatabase.schemas,
      directory: dir.path,
      name: 'podcast_player',
    );

    return _isar!;
  }

  /// Closes the Isar database.
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Returns the list of all Isar schemas used by this database.
  static List<CollectionSchema<dynamic>> get schemas => const [];
}
