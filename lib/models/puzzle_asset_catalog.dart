import 'package:flutter/services.dart';
import 'package:puzzle_match/logic/grid_validation.dart';
import 'package:puzzle_match/models/puzzle_image_ref.dart';
import 'package:puzzle_match/models/stage_config.dart';

class PuzzleAssetName {
  const PuzzleAssetName({
    required this.slot,
    required this.level,
    required this.id,
  });

  final int slot;
  final int level;
  final String id;
}

class PuzzleAssetCatalog {
  static const directory = 'assets/puzzles';
  static final pattern = RegExp(
    r'^(\d+)of5level(\d+)$',
    caseSensitive: false,
  );

  static PuzzleAssetName? parse(String filename) {
    final id = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;
    final match = pattern.firstMatch(id);
    if (match == null) return null;
    final slot = int.parse(match.group(1)!);
    final level = int.parse(match.group(2)!);
    if (slot < 1 || slot > GridValidation.maxImagesPerStage) return null;
    if (level < 1) return null;
    return PuzzleAssetName(slot: slot, level: level, id: id);
  }

  static Future<Map<int, List<PuzzleImageRef>>> loadFromBundle() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final byLevel = <int, List<(int slot, PuzzleImageRef image)>>{};
    for (final key in manifest.listAssets()) {
      if (!key.startsWith('$directory/')) continue;
      final filename = key.split('/').last;
      final parsed = parse(filename);
      if (parsed == null) continue;
      byLevel.putIfAbsent(parsed.level, () => []);
      byLevel[parsed.level]!.add((
        parsed.slot,
        PuzzleImageRef.asset(id: parsed.id, assetPath: key),
      ));
    }
    return {
      for (final entry in byLevel.entries)
        entry.key: [
          for (final item in (entry.value..sort((a, b) => a.$1.compareTo(b.$1))))
            item.$2,
        ],
    };
  }

  /// Puts bundled `{n}of5level{L}` images into both stages of that level.
  /// User-uploaded files are kept; generated placeholders are replaced.
  static GameConfig apply(
    GameConfig config,
    Map<int, List<PuzzleImageRef>> byLevel,
  ) {
    var result = config;
    for (final level in config.levels) {
      final bundled = byLevel[level.levelNumber];
      if (bundled == null || bundled.isEmpty) continue;
      for (final stage in level.stages) {
        final merged = <String, PuzzleImageRef>{
          for (final image in bundled) image.id: image,
        };
        for (final image in stage.images) {
          if (image.kind != PuzzleImageKind.file) continue;
          if (merged.length >= GridValidation.maxImagesPerStage) break;
          merged.putIfAbsent(image.id, () => image);
        }
        result = result.replacingStage(
          level.levelNumber,
          stage.copyWith(images: merged.values.toList()),
        );
      }
    }
    return result;
  }
}
