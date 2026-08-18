import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle_match/state/app_controller.dart';
import 'package:puzzle_match/theme/app_theme.dart';
import 'package:puzzle_match/ui/screens/game_screen.dart';
import 'package:puzzle_match/ui/screens/levels_screen.dart';
import 'package:puzzle_match/ui/screens/profile_screen.dart';
import 'package:puzzle_match/ui/screens/settings_screen.dart';
import 'package:puzzle_match/ui/motion.dart';
import 'package:puzzle_match/ui/widgets/game_controls.dart';
import 'package:puzzle_match/ui/widgets/puzzle_thumb.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final profile = app.profile;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            children: [
              Row(
                children: [
                  StatChip(
                    icon: Icons.monetization_on_rounded,
                    value: '${profile.coins}',
                  ),
                  const SizedBox(width: 8),
                  StatChip(
                    icon: Icons.lightbulb_rounded,
                    value: '${profile.hintPoints}',
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => AppMotion.open(
                      context,
                      const SettingsScreen(),
                    ),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'IMAGE PUZZLE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${profile.emoji}  ${profile.name}',
                style: const TextStyle(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PuzzleThumb(
                                image: app.config.stage(1, 1).images.first,
                                repository: app.images,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            profile.canResume
                                ? 'Level ${profile.resumeLevel} · Stage ${profile.resumeStage}'
                                : 'Tap Play to begin',
                            style: const TextStyle(
                              color: Color(0xFF5D4037),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GameButton(
                label: profile.canResume ? 'RESUME' : 'PLAY',
                onPressed: () => _start(context, app, resume: profile.canResume),
              ),
              const SizedBox(height: 10),
              GameButton(
                label: 'NEW GAME',
                primary: false,
                onPressed: () => _start(context, app, resume: false),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    onTap: () => AppMotion.open(context, const ProfileScreen()),
                  ),
                  _NavItem(
                    icon: Icons.map_rounded,
                    label: 'Levels',
                    onTap: () => AppMotion.open(context, const LevelsScreen()),
                  ),
                  _NavItem(
                    icon: Icons.tune_rounded,
                    label: 'Settings',
                    onTap: () => AppMotion.open(context, const SettingsScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(
    BuildContext context,
    AppController app, {
    required bool resume,
  }) async {
    final error = resume ? await app.resumeGame() : await app.startNewGame();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await AppMotion.open(context, const GameScreen());
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.hint),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
