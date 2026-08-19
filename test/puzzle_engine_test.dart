import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_match/logic/grid_validation.dart';
import 'package:puzzle_match/logic/group_detector.dart';
import 'package:puzzle_match/logic/puzzle_engine.dart';
import 'package:puzzle_match/logic/reward_service.dart';
import 'package:puzzle_match/logic/shuffle_service.dart';
import 'package:puzzle_match/models/profile.dart';
import 'package:puzzle_match/models/stage_config.dart';

void main() {
  group('GameConfig', () {
    final config = GameConfig.standard();

    test('starts at 2×2 and ends at 15×15 with two stages each', () {
      expect(config.levels.first.levelNumber, 1);
      expect(config.stage(1, 1).rows, 2);
      expect(config.stage(1, 1).columns, 2);
      expect(config.stage(2, 1).rows, 3);
      expect(config.stage(2, 1).columns, 2);
      expect(config.stage(3, 1).rows, 3);
      expect(config.stage(3, 1).columns, 3);
      final last = config.levels.last;
      expect(last.stages.first.rows, 15);
      expect(last.stages.first.columns, 15);
      expect(last.stages, hasLength(2));
    });

    test('timers stay between 60 and 120', () {
      for (final level in config.levels) {
        for (final stage in level.stages) {
          expect(stage.timerSeconds, inInclusiveRange(60, 120));
        }
      }
    });

    test('stages start with no generated fallback images', () {
      for (final level in config.levels) {
        for (final stage in level.stages) {
          expect(stage.images, isEmpty);
        }
      }
    });
  });

  group('GridValidation', () {
    test('accepts square and portrait grids', () {
      expect(GridValidation.isPortraitCompatible(2, 2), isTrue);
      expect(GridValidation.isPortraitCompatible(3, 2), isTrue);
      expect(GridValidation.isPortraitCompatible(15, 15), isTrue);
    });

    test('rejects landscape and out-of-range grids', () {
      expect(GridValidation.isPortraitCompatible(2, 3), isFalse);
      expect(GridValidation.isPortraitCompatible(4, 6), isFalse);
      expect(GridValidation.isPortraitCompatible(1, 1), isFalse);
      expect(GridValidation.isPortraitCompatible(16, 16), isFalse);
    });
  });

  group('ShuffleService', () {
    const shuffle = ShuffleService();

    test('is a permutation and never identity', () {
      final rng = Random(7);
      for (var n = 2; n <= 25; n++) {
        final tiles = shuffle.shuffle(n, random: rng);
        expect(tiles.toSet(), equals({for (var i = 0; i < n; i++) i}));
        expect(List.generate(n, (i) => i), isNot(equals(tiles)));
      }
    });
  });

  group('PuzzleEngine', () {
    test('swaps two individual tiles', () {
      final engine = PuzzleEngine(
        rows: 3,
        columns: 3,
        placement: [5, 8, 0, 2, 7, 6, 1, 4, 3],
      );
      expect(engine.tileIdAt(0), 5);
      final result = engine.moveGroup(grabbedIndex: 2, dropIndex: 0);
      expect(result.applied, isTrue);
      expect(engine.tileIdAt(0), 0);
      expect(engine.tileIdAt(2), 5);
      expect(engine.placement.toSet(), equals({0, 1, 2, 3, 4, 5, 6, 7, 8}));
    });

    test('moves a connected solved row as a group', () {
      final engine = PuzzleEngine(
        rows: 3,
        columns: 3,
        placement: [0, 1, 2, 5, 7, 3, 6, 4, 8],
      );
      expect(engine.groupAt(0).positions, equals({0, 1, 2}));
      final result = engine.moveGroup(grabbedIndex: 0, dropIndex: 3);
      expect(result.applied, isTrue);
      expect(engine.placement.sublist(0, 3), [5, 7, 3]);
      expect(engine.placement.sublist(3, 6), [0, 1, 2]);
      expect(engine.placement.toSet().length, 9);
    });

    test('rejects group moves that leave the board', () {
      final engine = PuzzleEngine(
        rows: 3,
        columns: 3,
        placement: [0, 1, 2, 3, 4, 5, 6, 7, 8],
      );
      final result = engine.moveGroup(grabbedIndex: 0, dropIndex: 1);
      expect(result.applied, isFalse);
    });

    test('hint always solves the first unsolved position', () {
      final engine = PuzzleEngine(
        rows: 3,
        columns: 3,
        placement: [5, 8, 0, 2, 7, 6, 1, 4, 3],
      );
      engine.applyHint();
      expect(engine.tileIdAt(0), 0);
      engine.applyHint();
      expect(engine.tileIdAt(1), 1);
      engine.applyHint();
      expect(engine.tileIdAt(2), 2);
      expect(engine.firstUnsolvedPosition(), isNot(0));
    });

    test('hint does not disturb already correct prefix', () {
      final engine = PuzzleEngine(
        rows: 3,
        columns: 3,
        placement: [0, 1, 5, 2, 7, 6, 8, 4, 3],
      );
      engine.applyHint();
      expect(engine.tileIdAt(0), 0);
      expect(engine.tileIdAt(1), 1);
      expect(engine.tileIdAt(2), 2);
    });

    test('15×15 remains a valid permutation after moves and hints', () {
      final engine = PuzzleEngine.shuffled(
        rows: 15,
        columns: 15,
        random: Random(42),
      );
      expect(engine.tileCount, 225);
      expect(engine.placement.toSet().length, 225);
      engine.moveGroup(grabbedIndex: 0, dropIndex: 10);
      engine.applyHint();
      expect(engine.placement.toSet().length, 225);
      expect(engine.isSolved, isFalse);
    });
  });

  group('GroupDetector', () {
    const detector = GroupDetector();

    test('connects relatively correct neighbors even when shifted', () {
      final placement = [3, 4, 5, 0, 1, 2, 6, 7, 8];
      expect(
        detector.areConnected(
          placement: placement,
          columns: 3,
          a: 0,
          b: 1,
        ),
        isTrue,
      );
      final groups = detector.detect(placement, 3);
      expect(groups.firstWhere((g) => g.contains(0)).size, greaterThanOrEqualTo(3));
    });
  });

  group('RewardService', () {
    const rewards = RewardService();

    test('is idempotent', () {
      final first = rewards.grantIfNeeded(alreadyGranted: false);
      final second = rewards.grantIfNeeded(alreadyGranted: true);
      expect(first.coins, 100);
      expect(first.hintPoints, 1);
      expect(second.coins, 0);
      expect(second.hintPoints, 0);
    });
  });

  group('PlayerProfile', () {
    test('keeps highest progress after a later loss replay', () {
      var profile = PlayerProfile.defaults().firstWhere((p) => p.id == 'tiger');
      profile = profile.withProgress(
        level: 7,
        stage: 2,
        completed: true,
        awardRewards: true,
      );
      profile = profile.copyWith(resumeLevel: 4, resumeStage: 1);
      expect(profile.highestLevel, 7);
      expect(profile.highestStage, 2);
      expect(profile.coins, 100);
    });

    test('unlocks the next stage only after completion', () {
      var profile = PlayerProfile.defaults().firstWhere((p) => p.id == 'lion');
      expect(profile.isUnlocked(1, 1), isTrue);
      expect(profile.isUnlocked(1, 2), isFalse);
      profile = profile.withProgress(
        level: 1,
        stage: 1,
        completed: true,
        awardRewards: true,
      );
      expect(profile.isUnlocked(1, 2), isTrue);
      expect(profile.isUnlocked(2, 1), isFalse);
    });
  });
}
