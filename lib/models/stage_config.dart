import 'package:puzzle_match/logic/grid_validation.dart';
import 'package:puzzle_match/models/puzzle_image_ref.dart';

class StageConfig {
  const StageConfig({
    required this.stageNumber,
    required this.rows,
    required this.columns,
    required this.timerSeconds,
    required this.images,
  });

  final int stageNumber;
  final int rows;
  final int columns;
  final int timerSeconds;
  final List<PuzzleImageRef> images;

  int get tileCount => rows * columns;

  StageConfig copyWith({
    int? stageNumber,
    int? rows,
    int? columns,
    int? timerSeconds,
    List<PuzzleImageRef>? images,
  }) {
    return StageConfig(
      stageNumber: stageNumber ?? this.stageNumber,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toJson() => {
    'stageNumber': stageNumber,
    'rows': rows,
    'columns': columns,
    'timerSeconds': timerSeconds,
    'images': images.map((image) => image.toJson()).toList(),
  };

  factory StageConfig.fromJson(Map<String, dynamic> json) {
    return StageConfig(
      stageNumber: json['stageNumber'] as int,
      rows: json['rows'] as int,
      columns: json['columns'] as int,
      timerSeconds: json['timerSeconds'] as int,
      images: (json['images'] as List<dynamic>)
          .map((item) => PuzzleImageRef.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LevelConfig {
  const LevelConfig({required this.levelNumber, required this.stages});

  final int levelNumber;
  final List<StageConfig> stages;

  StageConfig stage(int stageNumber) {
    return stages.firstWhere((stage) => stage.stageNumber == stageNumber);
  }

  Map<String, dynamic> toJson() => {
    'levelNumber': levelNumber,
    'stages': stages.map((stage) => stage.toJson()).toList(),
  };

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    return LevelConfig(
      levelNumber: json['levelNumber'] as int,
      stages: (json['stages'] as List<dynamic>)
          .map((item) => StageConfig.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GameConfig {
  const GameConfig({required this.levels});

  final List<LevelConfig> levels;

  static const int stagesPerLevel = 2;
  static const int minTimerSeconds = 60;
  static const int maxTimerSeconds = 120;

  int get levelCount => levels.length;

  LevelConfig level(int levelNumber) {
    return levels.firstWhere((item) => item.levelNumber == levelNumber);
  }

  StageConfig stage(int levelNumber, int stageNumber) {
    return level(levelNumber).stage(stageNumber);
  }

  bool hasLevel(int levelNumber) {
    return levels.any((item) => item.levelNumber == levelNumber);
  }

  (int level, int stage)? nextStage(int levelNumber, int stageNumber) {
    if (stageNumber < stagesPerLevel) {
      return (levelNumber, stageNumber + 1);
    }
    if (hasLevel(levelNumber + 1)) {
      return (levelNumber + 1, 1);
    }
    return null;
  }

  bool isLastStage(int levelNumber, int stageNumber) {
    return nextStage(levelNumber, stageNumber) == null;
  }

  GameConfig replacingStage(int levelNumber, StageConfig stageConfig) {
    return GameConfig(
      levels: [
        for (final level in levels)
          if (level.levelNumber == levelNumber)
            LevelConfig(
              levelNumber: level.levelNumber,
              stages: [
                for (final stage in level.stages)
                  if (stage.stageNumber == stageConfig.stageNumber)
                    stageConfig
                  else
                    stage,
              ],
            )
          else
            level,
      ],
    );
  }

  static int timerForGrid(int rows, int columns) {
    final scaled = minTimerSeconds + ((rows - 2) * 5) + ((columns - rows) * 2);
    if (scaled < minTimerSeconds) return minTimerSeconds;
    if (scaled > maxTimerSeconds) return maxTimerSeconds;
    return scaled;
  }

  /// Builds 2×2, 3×2, 3×3, 4×3, … up to 15×15. Two stages per level.
  factory GameConfig.standard() {
    final levels = <LevelConfig>[];
    var levelNumber = 1;
    for (var size = 2; size <= GridValidation.maxSize; size++) {
      levels.add(_level(levelNumber, size, size));
      levelNumber++;
      if (size < GridValidation.maxSize) {
        levels.add(_level(levelNumber, size + 1, size));
        levelNumber++;
      }
    }
    return GameConfig(levels: levels);
  }

  /// Keeps saved images but restores rows, columns, and timers from [standard].
  static GameConfig withStandardLayouts(GameConfig saved) {
    final standard = GameConfig.standard();
    var result = saved;
    for (final level in standard.levels) {
      if (!saved.hasLevel(level.levelNumber)) continue;
      for (final stage in level.stages) {
        final current = saved.stage(level.levelNumber, stage.stageNumber);
        result = result.replacingStage(
          level.levelNumber,
          current.copyWith(
            rows: stage.rows,
            columns: stage.columns,
            timerSeconds: stage.timerSeconds,
          ),
        );
      }
    }
    return result;
  }

  static LevelConfig _level(int levelNumber, int rows, int columns) {
    final timer = timerForGrid(rows, columns);
    return LevelConfig(
      levelNumber: levelNumber,
      stages: [
        for (var stageNumber = 1; stageNumber <= stagesPerLevel; stageNumber++)
          StageConfig(
            stageNumber: stageNumber,
            rows: rows,
            columns: columns,
            timerSeconds: timer,
            images: const [],
          ),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'levels': levels.map((level) => level.toJson()).toList(),
  };

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      levels: (json['levels'] as List<dynamic>)
          .map((item) => LevelConfig.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
