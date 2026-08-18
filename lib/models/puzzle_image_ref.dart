enum PuzzleImageKind { builtin, file }

class PuzzleImageRef {
  const PuzzleImageRef({
    required this.id,
    required this.kind,
    this.filePath,
    this.builtinIndex,
  });

  final String id;
  final PuzzleImageKind kind;
  final String? filePath;
  final int? builtinIndex;

  factory PuzzleImageRef.builtin(int index) {
    return PuzzleImageRef(
      id: 'builtin_$index',
      kind: PuzzleImageKind.builtin,
      builtinIndex: index,
    );
  }

  factory PuzzleImageRef.file({required String id, required String filePath}) {
    return PuzzleImageRef(
      id: id,
      kind: PuzzleImageKind.file,
      filePath: filePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'filePath': filePath,
    'builtinIndex': builtinIndex,
  };

  factory PuzzleImageRef.fromJson(Map<String, dynamic> json) {
    return PuzzleImageRef(
      id: json['id'] as String,
      kind: PuzzleImageKind.values.firstWhere(
        (value) => value.name == json['kind'],
        orElse: () => PuzzleImageKind.builtin,
      ),
      filePath: json['filePath'] as String?,
      builtinIndex: json['builtinIndex'] as int?,
    );
  }
}
