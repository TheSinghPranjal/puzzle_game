import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle_match/state/app_controller.dart';
import 'package:puzzle_match/theme/app_theme.dart';
import 'package:puzzle_match/ui/motion.dart';
import 'package:puzzle_match/ui/screens/game_screen.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Levels')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: app.config.levels.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final level = app.config.levels[index];
          final stage = level.stages.first;
          final unlocked = app.profile.isUnlocked(level.levelNumber, 1);
          final completed = app.profile.hasCompleted(level.levelNumber, 2);
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: AppTheme.surface,
            leading: CircleAvatar(
              backgroundColor: completed
                  ? AppTheme.success.withValues(alpha: 0.2)
                  : unlocked
                  ? AppTheme.accent.withValues(alpha: 0.2)
                  : Colors.white10,
              child: Icon(
                completed
                    ? Icons.check_rounded
                    : unlocked
                    ? Icons.star_rounded
                    : Icons.lock_rounded,
                color: completed
                    ? AppTheme.success
                    : unlocked
                    ? AppTheme.accent
                    : Colors.white38,
              ),
            ),
            title: Text('Level ${level.levelNumber}'),
            subtitle: Text(
              '${stage.rows} × ${stage.columns}  ·  ${stage.timerSeconds}s  ·  2 stages',
            ),
            enabled: unlocked,
            onTap: unlocked
                ? () async {
                    final stageNumber = app.profile.hasCompleted(
                      level.levelNumber,
                      1,
                    )
                        ? (app.profile.hasCompleted(level.levelNumber, 2)
                              ? 1
                              : 2)
                        : 1;
                    final error = await app.startStage(
                      level.levelNumber,
                      stageNumber,
                    );
                    if (!context.mounted) return;
                    if (error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error)));
                      return;
                    }
                    await AppMotion.open(context, const GameScreen());
                  }
                : null,
          );
        },
      ),
    );
  }
}
