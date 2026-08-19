import 'dart:math';

import 'package:puzzle_match/models/puzzle_image_ref.dart';

/// Picks stage images without repeating one until the rest of the pool
/// have been used in the current session.
class SessionImagePicker {
  SessionImagePicker();

  final Map<String, List<String>> _queue = {};
  final Map<String, String> _lastPicked = {};

  static String stageKey(int level, int stage) => '$level-$stage';

  void reset() {
    _queue.clear();
    _lastPicked.clear();
  }

  PuzzleImageRef next({
    required int level,
    required int stage,
    required List<PuzzleImageRef> pool,
    required Random random,
  }) {
    if (pool.isEmpty) {
      throw StateError('Cannot pick an image from an empty pool.');
    }
    final key = stageKey(level, stage);
    final byId = {for (final image in pool) image.id: image};
    var queue = [
      for (final id in _queue[key] ?? const <String>[])
        if (byId.containsKey(id)) id,
    ];

    if (queue.isEmpty) {
      queue = [...byId.keys]..shuffle(random);
      final last = _lastPicked[key];
      if (queue.length > 1 && last != null && queue.first == last) {
        queue.removeAt(0);
        queue.add(last);
      }
    }

    final id = queue.removeAt(0);
    _queue[key] = queue;
    _lastPicked[key] = id;
    return byId[id]!;
  }
}
