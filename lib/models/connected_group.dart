class ConnectedGroup {
  const ConnectedGroup({
    required this.id,
    required this.positions,
  });

  final int id;
  final Set<int> positions;

  bool contains(int position) => positions.contains(position);

  int get size => positions.length;
}
