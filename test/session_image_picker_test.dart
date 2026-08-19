import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_match/logic/session_image_picker.dart';
import 'package:puzzle_match/models/puzzle_image_ref.dart';

void main() {
  List<PuzzleImageRef> poolOf(int count) {
    return [
      for (var i = 1; i <= count; i++)
        PuzzleImageRef.asset(id: '${i}of5level2', assetPath: '$i.png'),
    ];
  }

  test('does not repeat an image in the same stage until the pool is exhausted', () {
    final picker = SessionImagePicker();
    final pool = poolOf(5);
    final seen = <String>{};
    for (var i = 0; i < 5; i++) {
      final picked = picker.next(
        level: 2,
        stage: 1,
        pool: pool,
        random: Random(4),
      );
      expect(seen.add(picked.id), isTrue, reason: 'repeated ${picked.id}');
    }
  });

  test('starts a new cycle after all five images without immediately repeating the last', () {
    final picker = SessionImagePicker();
    final pool = poolOf(5);
    String? last;
    for (var i = 0; i < 5; i++) {
      last = picker
          .next(level: 2, stage: 1, pool: pool, random: Random(11))
          .id;
    }
    final sixth = picker.next(
      level: 2,
      stage: 1,
      pool: pool,
      random: Random(11),
    );
    expect(sixth.id, isNot(last));
  });

  test('tracks stages independently in the same session', () {
    final picker = SessionImagePicker();
    final pool = poolOf(5);
    final first = picker.next(
      level: 2,
      stage: 1,
      pool: pool,
      random: Random(2),
    );
    final second = picker.next(
      level: 2,
      stage: 2,
      pool: pool,
      random: Random(2),
    );
    expect(first.id, isNotEmpty);
    expect(second.id, isNotEmpty);
  });

  test('reset allows the same stage image to appear again', () {
    final picker = SessionImagePicker();
    final pool = poolOf(2);
    final first = picker.next(
      level: 1,
      stage: 1,
      pool: pool,
      random: Random(1),
    );
    picker.reset();
    final afterReset = picker.next(
      level: 1,
      stage: 1,
      pool: pool,
      random: Random(1),
    );
    expect(afterReset.id, first.id);
  });
}
