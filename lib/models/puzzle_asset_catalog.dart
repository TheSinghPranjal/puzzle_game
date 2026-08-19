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
    final byLevel = <int, List<(int slot, PuzzleImageRef image)>>{};

    void add(PuzzleAssetName parsed, String path) {
      final current = byLevel.putIfAbsent(parsed.level, () => []);
      if (current.any((item) => item.$2.id == parsed.id)) return;
      current.add((
        parsed.slot,
        PuzzleImageRef.asset(id: parsed.id, assetPath: path),
      ));
    }

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    for (final key in manifest.listAssets()) {
      if (!key.contains('$directory/')) continue;
      final filename = key.split('/').last;
      final parsed = parse(filename);
      if (parsed == null) continue;
      add(parsed, key);
    }

    // AssetManifest can lag until a full rebuild. Probe sequential levels so
    // files like 1of5level2.png still attach to the 3×2 board.
    for (var level = 1; level <= GridValidation.maxSize * 2; level++) {
      var foundOnLevel = byLevel.containsKey(level);
      for (var slot = 1; slot <= GridValidation.maxImagesPerStage; slot++) {
        final id = '${slot}of5level$level';
        if (byLevel[level]?.any((item) => item.$2.id == id) == true) {
          foundOnLevel = true;
          continue;
        }
        final path = '$directory/$id.png';
        try {
          await rootBundle.load(path);
          add(parse('$id.png')!, path);
          foundOnLevel = true;
        } catch (_) {}
      }
      if (!foundOnLevel && level > 1) break;
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
  /// Also attaches them to any stage with that level's grid (for example
  /// `*of5level2` always fills 3×2). User-uploaded files are kept.
  /// Generated placeholders are never kept once a stage has real images.
  static GameConfig apply(
    GameConfig config,
    Map<int, List<PuzzleImageRef>> byLevel,
  ) {
    final imagesForGrid = <(int, int), List<PuzzleImageRef>>{};
    for (final level in GameConfig.standard().levels) {
      final bundled = byLevel[level.levelNumber];
      if (bundled == null || bundled.isEmpty) continue;
      final stage = level.stages.first;
      imagesForGrid[(stage.rows, stage.columns)] = bundled;
    }

    var result = config;
    for (final level in config.levels) {
      for (final stage in level.stages) {
        final fromLevel = byLevel[level.levelNumber] ?? const <PuzzleImageRef>[];
        final fromGrid =
            imagesForGrid[(stage.rows, stage.columns)] ?? const <PuzzleImageRef>[];
        final bundled = fromLevel.isNotEmpty ? fromLevel : fromGrid;
        result = result.replacingStage(
          level.levelNumber,
          stage.copyWith(
            images: _mergeStageImages(bundled: bundled, existing: stage.images),
          ),
        );
      }
    }
    return result;
  }

  static List<PuzzleImageRef> withoutGenerated(List<PuzzleImageRef> images) {
    return [
      for (final image in images)
        if (!image.isGenerated) image,
    ];
  }

  static List<PuzzleImageRef> _mergeStageImages({
    required List<PuzzleImageRef> bundled,
    required List<PuzzleImageRef> existing,
  }) {
    final merged = <String, PuzzleImageRef>{
      for (final image in bundled) image.id: image,
    };
    for (final image in existing) {
      if (image.isGenerated) continue;
      if (merged.containsKey(image.id)) continue;
      if (merged.length >= GridValidation.maxImagesPerStage) break;
      if (image.kind == PuzzleImageKind.file) {
        merged[image.id] = image;
        continue;
      }
      if (image.kind == PuzzleImageKind.asset && bundled.isEmpty) {
        merged[image.id] = image;
      }
    }
    return merged.values.toList();
  }
}
