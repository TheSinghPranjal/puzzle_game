enum GamePhase { countdown, playing, paused, completed, failed }

class PuzzleSnapshot {
  const PuzzleSnapshot({
    required this.level,
    required this.stage,
    required this.imageId,
    required this.placement,
    required this.remainingMs,
    required this.phase,
  });

  final int level;
  final int stage;
  final String imageId;
  final List<int> placement;
  final int remainingMs;
  final GamePhase phase;

  Map<String, dynamic> toJson() => {
    'level': level,
    'stage': stage,
    'imageId': imageId,
    'placement': placement,
    'remainingMs': remainingMs,
    'phase': phase.name,
  };

  factory PuzzleSnapshot.fromJson(Map<String, dynamic> json) {
    return PuzzleSnapshot(
      level: json['level'] as int,
      stage: json['stage'] as int,
      imageId: json['imageId'] as String,
      placement: (json['placement'] as List<dynamic>).cast<int>(),
      remainingMs: json['remainingMs'] as int,
      phase: GamePhase.values.firstWhere(
        (value) => value.name == json['phase'],
        orElse: () => GamePhase.paused,
      ),
    );
  }
}
