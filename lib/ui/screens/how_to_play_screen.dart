import 'package:flutter/material.dart';
import 'package:puzzle_match/theme/app_theme.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to play')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _Tip(
            title: 'Drag to swap',
            body:
                'There is no empty slot. Drag any tile onto another tile to swap them.',
          ),
          _Tip(
            title: 'Matching pieces stick',
            body:
                'When neighboring pieces of the image line up correctly, the separator disappears and they move as one group.',
          ),
          _Tip(
            title: 'Hints',
            body:
                'Each completed stage gives 1 hint and 100 coins. A hint places the next unsolved tile in its correct position.',
          ),
          _Tip(
            title: 'Timer',
            body:
                'Solve the board before time runs out. Pause freezes the clock. Resume Game returns you to the unfinished stage.',
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.panel(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: AppTheme.muted(context), height: 1.4)),
        ],
      ),
    );
  }
}
