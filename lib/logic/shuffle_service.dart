import 'dart:math';

class ShuffleService {
  const ShuffleService();

  /// Fisher–Yates shuffle that always contains each index once and is never
  /// already solved. [random] is injectable for tests.
  List<int> shuffle(int tileCount, {Random? random}) {
    if (tileCount <= 1) return List<int>.generate(tileCount, (i) => i);
    final rng = random ?? Random();
    List<int> tiles;
    var attempts = 0;
    do {
      tiles = List<int>.generate(tileCount, (i) => i);
      for (var i = tileCount - 1; i > 0; i--) {
        final j = rng.nextInt(i + 1);
        final tmp = tiles[i];
        tiles[i] = tiles[j];
        tiles[j] = tmp;
      }
      attempts++;
    } while (_isIdentity(tiles) && attempts < 40);
    if (_isIdentity(tiles) && tileCount > 1) {
      final tmp = tiles[0];
      tiles[0] = tiles[1];
      tiles[1] = tmp;
    }
    return tiles;
  }

  bool _isIdentity(List<int> tiles) {
    for (var i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) return false;
    }
    return true;
  }
}
