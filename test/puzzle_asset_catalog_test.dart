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
      expect(config.stage(2, 1).images, isEmpty);
    });

    test('puts all five 3×2 images on both Level 2 stages', () {
      final config = PuzzleAssetCatalog.apply(GameConfig.standard(), {
        2: [
          for (var slot = 1; slot <= 5; slot++)
            PuzzleImageRef.asset(
              id: '${slot}of5level2',
              assetPath: 'assets/puzzles/${slot}of5level2.png',
            ),
        ],
      });
      expect(config.stage(2, 1).rows, 3);
      expect(config.stage(2, 1).columns, 2);
      expect(config.stage(2, 1).images, hasLength(5));
      expect(config.stage(2, 2).images, hasLength(5));
      expect(
        config.stage(2, 1).images.map((image) => image.id).toList(),
        ['1of5level2', '2of5level2', '3of5level2', '4of5level2', '5of5level2'],
      );
    });

    test('fills a 3×2 stage from Level 2 images even if the level number differs', () {
      final shifted = GameConfig.standard().replacingStage(
        4,
        GameConfig.standard().stage(4, 1).copyWith(rows: 3, columns: 2),
      );
      final config = PuzzleAssetCatalog.apply(shifted, {
        2: [
          PuzzleImageRef.asset(
            id: '1of5level2',
            assetPath: 'assets/puzzles/1of5level2.png',
          ),
        ],
      });
      expect(config.stage(4, 1).images.single.id, '1of5level2');
    });

    test('drops generated placeholders when a level already has real images', () {
      final mixed = GameConfig.standard().replacingStage(
        3,
        GameConfig.standard().stage(3, 1).copyWith(
          images: [
            PuzzleImageRef.builtin(7),
            PuzzleImageRef.file(id: 'file_city', filePath: '/tmp/city.png'),
          ],
        ),
      );
      final config = PuzzleAssetCatalog.apply(mixed, const {});
      expect(config.stage(3, 1).images.single.id, 'file_city');
      expect(config.stage(3, 1).images.single.kind, PuzzleImageKind.file);
    });

    test('replaces generated placeholders with bundled images', () {
      final saved = GameConfig.standard().replacingStage(
        1,
        GameConfig.standard().stage(1, 1).copyWith(
          images: [PuzzleImageRef.builtin(0), PuzzleImageRef.builtin(3)],
        ),
      );
      final config = PuzzleAssetCatalog.apply(saved, {
        1: [
          PuzzleImageRef.asset(
            id: '1of5level1',
            assetPath: 'assets/puzzles/1of5level1.png',
          ),
        ],
      });
      expect(config.stage(1, 1).images.single.id, '1of5level1');
      expect(
        config.stage(1, 1).images.any((image) => image.isGenerated),
        isFalse,
      );
    });
  });
}
