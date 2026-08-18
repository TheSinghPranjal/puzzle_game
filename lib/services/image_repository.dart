import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:puzzle_match/models/puzzle_image_ref.dart';
import 'package:puzzle_match/services/builtin_images.dart';

class ImageLoadException implements Exception {
  ImageLoadException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ImageRepository {
  ImageRepository({BuiltinImageGenerator generator = const BuiltinImageGenerator()})
    : _generator = generator;

  final BuiltinImageGenerator _generator;
  final Map<String, ui.Image> _images = {};
  final Map<String, Uint8List> _png = {};

  Future<ui.Image> resolve(PuzzleImageRef ref) async {
    final cached = _images[ref.id];
    if (cached != null) return cached;
    final image = switch (ref.kind) {
      PuzzleImageKind.builtin => await _generator.render(ref.builtinIndex ?? 0),
      PuzzleImageKind.file => await _decodeFile(ref.filePath!),
      PuzzleImageKind.asset => await _decodeAsset(ref.assetPath ?? ''),
    };
    _images[ref.id] = image;
    return image;
  }

  Future<Uint8List> pngBytes(PuzzleImageRef ref) async {
    final cached = _png[ref.id];
    if (cached != null) return cached;
    final image = await resolve(ref);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw ImageLoadException('Could not encode image ${ref.id}.');
    }
    final png = bytes.buffer.asUint8List();
    _png[ref.id] = png;
    return png;
  }

  Future<PuzzleImageRef> importPickedFile(String sourcePath) async {
    final decoded = await _decodeFile(sourcePath);
    if (decoded.width < 8 || decoded.height < 8) {
      decoded.dispose();
      throw ImageLoadException('Image is too small to use as a puzzle.');
    }
    final dir = await _puzzlesDir();
    final id = 'file_${DateTime.now().millisecondsSinceEpoch}';
    final dest = p.join(dir.path, '$id.png');
    final bytes = await decoded.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      decoded.dispose();
      throw ImageLoadException('Could not save the selected image.');
    }
    await File(dest).writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    _images[id] = decoded;
    return PuzzleImageRef.file(id: id, filePath: dest);
  }

  Future<void> deleteFile(PuzzleImageRef ref) async {
    if (ref.kind != PuzzleImageKind.file || ref.filePath == null) return;
    _images.remove(ref.id)?.dispose();
    _png.remove(ref.id);
    final file = File(ref.filePath!);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<ui.Image> _decodeAsset(String assetPath) async {
    if (assetPath.isEmpty) {
      throw ImageLoadException('Puzzle asset path is missing.');
    }
    try {
      final data = await rootBundle.load(assetPath);
      return decodeImage(data.buffer.asUint8List());
    } catch (error) {
      if (error is ImageLoadException) rethrow;
      throw ImageLoadException('Could not load puzzle asset $assetPath.');
    }
  }

  Future<ui.Image> _decodeFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw ImageLoadException('Image file is missing.');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw ImageLoadException('Image file is empty.');
    }
    return decodeImage(bytes);
  }

  static Future<ui.Image> decodeImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      throw ImageLoadException('Unsupported or corrupted image.');
    }
  }

  Future<Directory> _puzzlesDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'puzzles'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  void dispose() {
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
    _png.clear();
  }
}
