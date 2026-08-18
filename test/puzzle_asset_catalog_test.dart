import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_match/models/puzzle_asset_catalog.dart';
import 'package:puzzle_match/models/puzzle_image_ref.dart';
import 'package:puzzle_match/models/stage_config.dart';

void main() {
  group('PuzzleAssetCatalog.parse', () {
    test('reads 1of5level1', () {
      final parsed = PuzzleAssetCatalog.parse('1of5level1.png');
      expect(parsed?.slot, 1);
      expect(parsed?.level, 1);
      expect(parsed?.id, '1of5level1');
    });

    test('reads later slots and levels', () {
      final parsed = PuzzleAssetCatalog.parse('5of5level12.jpg');
      expect(parsed?.slot, 5);
      expect(parsed?.level, 12);
    });

    test('rejects invalid names', () {
      expect(PuzzleAssetCatalog.parse('landscape.png'), isNull);
      expect(PuzzleAssetCatalog.parse('0of5level1.png'), isNull);
      expect(PuzzleAssetCatalog.parse('6of5level1.png'), isNull);
    });
  });

  group('PuzzleAssetCatalog.apply', () {
    test('puts bundled images on both stages of the matching level', () {
      final config = PuzzleAssetCatalog.apply(GameConfig.standard(), {
        1: [
          PuzzleImageRef.asset(
            id: '1of5level1',
            assetPath: 'assets/puzzles/1of5level1.png',
          ),
        ],
      });
      expect(config.stage(1, 1).images.single.id, '1of5level1');
      expect(config.stage(1, 2).images.single.id, '1of5level1');
      expect(config.stage(1, 1).rows, 2);
      expect(config.stage(1, 1).columns, 2);
      expect(config.stage(2, 1).images.first.kind, PuzzleImageKind.builtin);
    });
  });
}
