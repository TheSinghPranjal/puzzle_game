import 'package:puzzle_match/models/connected_group.dart';

class GroupDetector {
  const GroupDetector();

  /// Two currently adjacent tiles form an edge when they are also adjacent in
  /// the same relative direction in the solved image. That lets assembled
  /// chunks stay grouped and move as a unit even if they are not yet in their
  /// final board location.
  bool areConnected({
    required List<int> placement,
    required int columns,
    required int a,
    required int b,
  }) {
    final rows = placement.length ~/ columns;
    final aRow = a ~/ columns;
    final aCol = a % columns;
    final bRow = b ~/ columns;
    final bCol = b % columns;
    final dRow = bRow - aRow;
    final dCol = bCol - aCol;
    if (dRow.abs() + dCol.abs() != 1) return false;
    if (bRow < 0 || bRow >= rows || bCol < 0 || bCol >= columns) return false;

    final idA = placement[a];
    final idB = placement[b];
    final correctDRow = (idB ~/ columns) - (idA ~/ columns);
    final correctDCol = (idB % columns) - (idA % columns);
    return dRow == correctDRow && dCol == correctDCol;
  }

  bool isTileCorrect(List<int> placement, int position) =>
      placement[position] == position;

  List<ConnectedGroup> detect(List<int> placement, int columns) {
    final count = placement.length;
    final visited = List<bool>.filled(count, false);
    final groups = <ConnectedGroup>[];
    var groupId = 0;

    for (var start = 0; start < count; start++) {
      if (visited[start]) continue;
      final positions = <int>{};
      final queue = <int>[start];
      visited[start] = true;
      while (queue.isNotEmpty) {
        final current = queue.removeLast();
        positions.add(current);
        for (final neighbor in _neighbors(current, columns, count)) {
          if (visited[neighbor]) continue;
          if (!areConnected(
            placement: placement,
            columns: columns,
            a: current,
            b: neighbor,
          )) {
            continue;
          }
          visited[neighbor] = true;
          queue.add(neighbor);
        }
      }
      groups.add(ConnectedGroup(id: groupId, positions: positions));
      groupId++;
    }
    return groups;
  }

  ConnectedGroup groupAt(List<ConnectedGroup> groups, int position) {
    return groups.firstWhere((group) => group.contains(position));
  }

  Iterable<int> _neighbors(int index, int columns, int count) sync* {
    final row = index ~/ columns;
    final col = index % columns;
    final rows = count ~/ columns;
    if (row > 0) yield index - columns;
    if (row < rows - 1) yield index + columns;
    if (col > 0) yield index - 1;
    if (col < columns - 1) yield index + 1;
  }
}
