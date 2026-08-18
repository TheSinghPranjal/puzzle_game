class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.name,
    required this.emoji,
    required this.coins,
    required this.hintPoints,
    required this.highestLevel,
    required this.highestStage,
    required this.resumeLevel,
    required this.resumeStage,
    required this.hasStarted,
    required this.completedKeys,
  });

  final String id;
  final String name;
  final String emoji;
  final int coins;
  final int hintPoints;
  final int highestLevel;
  final int highestStage;
  final int resumeLevel;
  final int resumeStage;
  final bool hasStarted;
  final Set<String> completedKeys;

  static const defaultProfileId = 'tiger';

  static List<PlayerProfile> defaults() {
    const avatars = <(String, String, String)>[
      ('lion', 'Lion', '🦁'),
      ('tiger', 'Tiger', '🐯'),
      ('bear', 'Bear', '🐻'),
      ('wolf', 'Wolf', '🐺'),
      ('eagle', 'Eagle', '🦅'),
    ];
    return [
      for (final avatar in avatars)
        PlayerProfile(
          id: avatar.$1,
          name: avatar.$2,
          emoji: avatar.$3,
          coins: 0,
          hintPoints: 0,
          highestLevel: 1,
          highestStage: 1,
          resumeLevel: 1,
          resumeStage: 1,
          hasStarted: false,
          completedKeys: const {},
        ),
    ];
  }

  static String stageKey(int level, int stage) => '$level-$stage';

  bool get canResume => hasStarted;

  bool hasCompleted(int level, int stage) =>
      completedKeys.contains(stageKey(level, stage));

  bool isUnlocked(int level, int stage) {
    if (level == 1 && stage == 1) return true;
    if (stage == 2) return hasCompleted(level, 1);
    return hasCompleted(level - 1, 2);
  }

  PlayerProfile copyWith({
    int? coins,
    int? hintPoints,
    int? highestLevel,
    int? highestStage,
    int? resumeLevel,
    int? resumeStage,
    bool? hasStarted,
    Set<String>? completedKeys,
  }) {
    return PlayerProfile(
      id: id,
      name: name,
      emoji: emoji,
      coins: coins ?? this.coins,
      hintPoints: hintPoints ?? this.hintPoints,
      highestLevel: highestLevel ?? this.highestLevel,
      highestStage: highestStage ?? this.highestStage,
      resumeLevel: resumeLevel ?? this.resumeLevel,
      resumeStage: resumeStage ?? this.resumeStage,
      hasStarted: hasStarted ?? this.hasStarted,
      completedKeys: completedKeys ?? this.completedKeys,
    );
  }

  PlayerProfile withProgress({
    required int level,
    required int stage,
    required bool completed,
    required bool awardRewards,
  }) {
    var nextHighestLevel = highestLevel;
    var nextHighestStage = highestStage;
    if (level > highestLevel ||
        (level == highestLevel && stage > highestStage)) {
      nextHighestLevel = level;
      nextHighestStage = stage;
    }

    final keys = Set<String>.from(completedKeys);
    var nextCoins = coins;
    var nextHints = hintPoints;
    if (completed) {
      keys.add(stageKey(level, stage));
      if (awardRewards) {
        nextCoins += 100;
        nextHints += 1;
      }
    }

    return copyWith(
      coins: nextCoins,
      hintPoints: nextHints,
      highestLevel: nextHighestLevel,
      highestStage: nextHighestStage,
      resumeLevel: level,
      resumeStage: stage,
      hasStarted: true,
      completedKeys: keys,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'coins': coins,
    'hintPoints': hintPoints,
    'highestLevel': highestLevel,
    'highestStage': highestStage,
    'resumeLevel': resumeLevel,
    'resumeStage': resumeStage,
    'hasStarted': hasStarted,
    'completedKeys': completedKeys.toList(),
  };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🐯',
      coins: json['coins'] as int? ?? 0,
      hintPoints: json['hintPoints'] as int? ?? 0,
      highestLevel: json['highestLevel'] as int? ?? 1,
      highestStage: json['highestStage'] as int? ?? 1,
      resumeLevel: json['resumeLevel'] as int? ?? 1,
      resumeStage: json['resumeStage'] as int? ?? 1,
      hasStarted: json['hasStarted'] as bool? ?? false,
      completedKeys: {
        for (final key in (json['completedKeys'] as List<dynamic>? ?? const []))
          key as String,
      },
    );
  }
}
