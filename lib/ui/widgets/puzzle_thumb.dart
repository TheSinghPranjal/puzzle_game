import 'package:flutter/material.dart';
import 'package:puzzle_match/models/puzzle_image_ref.dart';
import 'package:puzzle_match/services/image_repository.dart';

class PuzzleThumb extends StatelessWidget {
  const PuzzleThumb({super.key, required this.image, required this.repository});

  final PuzzleImageRef image;
  final ImageRepository repository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repository.pngBytes(image),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ColoredBox(
            color: Color(0xFF5D4037),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        );
      },
    );
  }
}
