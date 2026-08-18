import 'dart:math';

import 'package:puzzle_match/logic/group_detector.dart';
import 'package:puzzle_match/logic/shuffle_service.dart';
import 'package:puzzle_match/models/connected_group.dart';

class MoveResult {
  const MoveResult({
    required this.applied,
    this.solvedPositionIndexes = const {},
  });

  final bool applied;
  final Set<int> solvedPositionIndexes;

  static const rejected = MoveResult(applied: false);
}

class PuzzleEngine {
  PuzzleEngine({
    required this.rows,
    required this.columns,
    required List<int> placement,
    ShuffleService shuffleService = const ShuffleService(),
    GroupDetector groupDetector = const GroupDetector(),
  }) : _placement = List<int>.from(placement),
       _shuffleService = shuffleService,
       _groups = groupDetector {
    _recalculate();
    _assertValid();
  }

  factory PuzzleEngine.shuffled({
    required int rows,
    required int columns,
    Random? random,
    ShuffleService shuffleService = const ShuffleService(),
    GroupDetector groupDetector = const GroupDetector(),
  }) {
    return PuzzleEngine(
      rows: rows,
      columns: columns,
      placement: shuffleService.shuffle(rows * columns, random: random),
      shuffleService: shuffleService,
      groupDetector: groupDetector,
    );
  }

  final int rows;
  final int columns;
  final ShuffleService _shuffleService;
  final GroupDetector _groups;

  List<int> _placement;
  List<ConnectedGroup> _connectedGroups = const [];

  int get tileCount => rows * columns;

  List<int> get placement => List<int>.unmodifiable(_placement);

  List<ConnectedGroup> get groups =>
      List<ConnectedGroup>.unmodifiable(_connectedGroups);

  bool get isSolved {
    for (var i = 0; i < _placement.length; i++) {
      if (_placement[i] != i) return false;
    }
    return true;
  }

  int tileIdAt(int position) => _placement[position];

  int positionOf(int tileId) => _placement.indexOf(tileId);

  bool isCorrect(int position) => _placement[position] == position;

  ConnectedGroup groupAt(int position) =>
      _groups.groupAt(_connectedGroups, position);

  bool sharesGroup(int a, int b) => groupAt(a).contains(b);

  bool isEdgeConnected(int a, int b) {
    return _groups.areConnected(
      placement: _placement,
      columns: columns,
      a: a,
      b: b,
    );
  }

  int? firstUnsolvedPosition() {
    for (var i = 0; i < _placement.length; i++) {
      if (_placement[i] != i) return i;
    }
    return null;
  }

  /// Translates the connected group containing [grabbedIndex] so that tile
  /// lands on [dropIndex], swapping displaced tiles into vacated cells.
  MoveResult moveGroup({required int grabbedIndex, required int dropIndex}) {
    if (grabbedIndex == dropIndex) return MoveResult.rejected;
    if (!_inRange(grabbedIndex) || !_inRange(dropIndex)) {
      return MoveResult.rejected;
    }

    final source = groupAt(grabbedIndex);
    if (source.contains(dropIndex)) return MoveResult.rejected;

    final grabbedRow = grabbedIndex ~/ columns;
    final grabbedCol = grabbedIndex % columns;
    final dropRow = dropIndex ~/ columns;
    final dropCol = dropIndex % columns;
    final dRow = dropRow - grabbedRow;
    final dCol = dropCol - grabbedCol;

    final sourcePositions = source.positions.toList()..sort();
    final destPositions = <int>[];
    for (final index in sourcePositions) {
      final row = index ~/ columns + dRow;
      final col = index % columns + dCol;
      if (row < 0 || row >= rows || col < 0 || col >= columns) {
        return MoveResult.rejected;
      }
      destPositions.add(row * columns + col);
    }

    final sourceSet = sourcePositions.toSet();
    final destSet = destPositions.toSet();
    if (sourceSet.containsAll(destSet)) return MoveResult.rejected;

    final vacated = sourceSet.difference(destSet).toList()..sort();
    final incoming = destSet.difference(sourceSet).toList()..sort();
    if (vacated.length != incoming.length) return MoveResult.rejected;

    final before = List<int>.from(_placement);
    final displacedIds = [for (final index in incoming) _placement[index]];

    for (var i = 0; i < sourcePositions.length; i++) {
      final from = sourcePositions[i];
      final toRow = from ~/ columns + dRow;
      final toCol = from % columns + dCol;
      _placement[toRow * columns + toCol] = before[from];
    }
    for (var i = 0; i < displacedIds.length; i++) {
      _placement[vacated[i]] = displacedIds[i];
    }

    if (!_isPermutation(_placement)) {
      _placement = before;
      return MoveResult.rejected;
    }

    final solved = <int>{};
    for (var i = 0; i < _placement.length; i++) {
      if (before[i] != i && _placement[i] == i) solved.add(i);
    }
    _recalculate();
    return MoveResult(applied: true, solvedPositionIndexes: solved);
  }

  /// Swaps the tiles at two positions. Used by the hint system.
  MoveResult swapPositions(int a, int b) {
    if (a == b || !_inRange(a) || !_inRange(b)) return MoveResult.rejected;
    final before = List<int>.from(_placement);
    final tmp = _placement[a];
    _placement[a] = _placement[b];
    _placement[b] = tmp;
    final solved = <int>{};
    for (final index in [a, b]) {
      if (before[index] != index && _placement[index] == index) {
        solved.add(index);
      }
    }
    _recalculate();
    return MoveResult(applied: true, solvedPositionIndexes: solved);
  }

  /// Places the correct tile into the first unsolved position.
  MoveResult applyHint() {
    final unsolved = firstUnsolvedPosition();
    if (unsolved == null) return MoveResult.rejected;
    final source = positionOf(unsolved);
    return swapPositions(unsolved, source);
  }

  void restorePlacement(List<int> placement) {
    if (placement.length != tileCount || !_isPermutation(placement)) {
      throw ArgumentError('Invalid board placement.');
    }
    _placement = List<int>.from(placement);
    _recalculate();
  }

  void reshuffle({Random? random}) {
    _placement = _shuffleService.shuffle(tileCount, random: random);
    _recalculate();
  }

  void _recalculate() {
    _connectedGroups = _groups.detect(_placement, columns);
  }

  bool _inRange(int index) => index >= 0 && index < tileCount;

  bool _isPermutation(List<int> tiles) {
    if (tiles.length != tileCount) return false;
    final seen = <int>{};
    for (final tile in tiles) {
      if (tile < 0 || tile >= tileCount) return false;
      if (!seen.add(tile)) return false;
    }
    return seen.length == tileCount;
  }

  void _assertValid() {
    if (!_isPermutation(_placement)) {
      throw StateError('Puzzle board is not a valid permutation.');
    }
  }
}
