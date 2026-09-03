import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/player_state.dart';

/// Provider for the current player state.
/// This will be fully implemented in Phase 4.
final playerProvider = StateProvider<PlayerState?>((ref) => null);
