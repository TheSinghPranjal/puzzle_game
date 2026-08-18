import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle_match/models/puzzle_image_ref.dart';
import 'package:puzzle_match/state/app_controller.dart';
import 'package:puzzle_match/ui/motion.dart';
import 'package:puzzle_match/ui/screens/game_screen.dart';
import 'package:puzzle_match/ui/screens/levels_screen.dart';
import 'package:puzzle_match/ui/screens/profile_screen.dart';
import 'package:puzzle_match/ui/screens/settings_screen.dart';
import 'package:puzzle_match/ui/widgets/puzzle_thumb.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _navy = Color(0xFF0B1520);
  static const _navyMid = Color(0xFF152433);
  static const _gold = Color(0xFFFFC107);
  static const _goldDeep = Color(0xFFFF6B00);
  static const _cream = Color(0xFFF8EED8);
  static const _brown = Color(0xFF3E2A18);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final profile = app.profile;
    final resumeLevel = profile.canResume ? profile.resumeLevel : 1;
    final resumeStage = profile.canResume ? profile.resumeStage : 1;
    final preview = _previewImage(app, resumeLevel, resumeStage);

    return Scaffold(
      backgroundColor: _navy,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.15),
            radius: 1.15,
            colors: [_navyMid, _navy, Color(0xFF070B10)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _TopBar(
                  coins: profile.coins,
                  hints: profile.hintPoints,
                  onSettings: () =>
                      AppMotion.open(context, const SettingsScreen()),
                ),
              ),
              const SizedBox(height: 10),
              const _TitleBlock(),
              const SizedBox(height: 6),
              Text(
                '${profile.emoji}  ${profile.name}',
                style: const TextStyle(
                  color: Color(0xFF9AA7B5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _PreviewCard(
                    image: preview,
                    repository: app.images,
                    label: 'Level $resumeLevel  •  Stage $resumeStage',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _ResumeButton(
                  label: profile.canResume ? 'RESUME' : 'PLAY',
                  onPressed: () =>
                      _start(context, app, resume: profile.canResume),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _NewGameButton(
                  onPressed: () => _start(context, app, resume: false),
                ),
              ),
              const SizedBox(height: 14),
              _BottomNav(
                onProfile: () =>
                    AppMotion.open(context, const ProfileScreen()),
                onLevels: () => AppMotion.open(context, const LevelsScreen()),
                onSettings: () =>
                    AppMotion.open(context, const SettingsScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PuzzleImageRef _previewImage(AppController app, int level, int stage) {
    final images = app.config.stage(level, stage).images;
    if (images.isEmpty) return app.config.stage(1, 1).images.first;
    return images.first;
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.coins,
    required this.hints,
    required this.onSettings,
  });

  final int coins;
  final int hints;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatPill(
          leading: const _GoldCoin(size: 18),
          value: '$coins',
        ),
        const SizedBox(width: 8),
        _StatPill(
          leading: const Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFFFFD54F),
            size: 18,
          ),
          value: '$hints',
        ),
        const Spacer(),
        Pressable(
          onPressed: onSettings,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2733),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3A4A58)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.settings_rounded, color: Color(0xFFD0D6DC)),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.leading, required this.value});

  final Widget leading;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC121C26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66FFC107), width: 1),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldCoin extends StatelessWidget {
  const _GoldCoin({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF59D), Color(0xFFFFB300), Color(0xFFF57F17)],
        ),
      ),
      child: Center(
        child: Text(
          '\$',
          style: TextStyle(
            color: const Color(0xFF5D3A00),
            fontWeight: FontWeight.w900,
            fontSize: size * 0.62,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.6,
      height: 1,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'IMAGE  ',
          style: base.copyWith(
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
        ),
        Stack(
          children: [
            Transform.translate(
              offset: const Offset(0, 3.5),
              child: Text(
                'PUZZLE',
                style: base.copyWith(color: const Color(0xFF7A2E00)),
              ),
            ),
            Text(
              'PUZZLE',
              style: base.copyWith(
                color: const Color(0xFFFFC107),
                shadows: [
                  Shadow(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.45),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.image,
    required this.repository,
    required this.label,
  });

  final PuzzleImageRef image;
  final dynamic repository;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeScreen._cream,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE8D7B0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: PuzzleThumb(image: image, repository: repository),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomPaint(size: Size(22, 14), painter: _SprigPainter(true)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: HomeScreen._brown,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const CustomPaint(size: Size(22, 14), painter: _SprigPainter(false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SprigPainter extends CustomPainter {
  const _SprigPainter(this.left);

  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC4A574)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dir = left ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(left ? 0 : size.width, size.height * 0.55)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 0.1,
        left ? size.width : 0,
        size.height * 0.45,
      );
    canvas.drawPath(path, paint);
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (left ? 0.25 + i * 0.25 : 0.75 - i * 0.25), 5.0 + i * 2),
          width: 6,
          height: 3.5,
        ),
        Paint()..color = const Color(0xFFC4A574),
      );
    }
    dir;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ResumeButton extends StatelessWidget {
  const _ResumeButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Pressable(
          onPressed: onPressed,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF6B00),
                    Color(0xFFFF9800),
                    Color(0xFFFFC107),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.55),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 4,
                    height: 20,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.38),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(left: 18, top: -6, child: _Sparkle()),
        const Positioned(right: 22, top: -4, child: _Sparkle(small: true)),
        const Positioned(right: 8, bottom: -2, child: _Sparkle()),
        const Positioned(left: 40, bottom: -6, child: _Sparkle(small: true)),
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({this.small = false});

  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 7.0 : 10.0;
    return CustomPaint(size: Size(size, size), painter: const _SparklePainter());
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, size.height), paint);
    canvas.drawLine(Offset(0, c.dy), Offset(size.width, c.dy), paint);
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.22),
      Offset(size.width * 0.78, size.height * 0.78),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.22),
      Offset(size.width * 0.22, size.height * 0.78),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NewGameButton extends StatelessWidget {
  const _NewGameButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF0E141C),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFF6B00), width: 2),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.extension_rounded, color: Color(0xFFFFC107), size: 22),
              SizedBox(width: 8),
              Text(
                'NEW GAME',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.onProfile,
    required this.onLevels,
    required this.onSettings,
  });

  final VoidCallback onProfile;
  final VoidCallback onLevels;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xE60B1520),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavTab(
              icon: Icons.person_outline_rounded,
              label: 'PROFILE',
              onTap: onProfile,
            ),
          ),
          Expanded(
            child: _NavTab(
              icon: Icons.extension_rounded,
              label: 'LEVELS',
              selected: true,
              onTap: onLevels,
            ),
          ),
          Expanded(
            child: _NavTab(
              icon: Icons.tune_rounded,
              label: 'SETTINGS',
              onTap: onSettings,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: selected
              ? BoxDecoration(
                  color: const Color(0xFF1C2A38),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.28),
                      blurRadius: 10,
                    ),
                  ],
                )
              : null,
          child: Icon(icon, color: const Color(0xFFFFC107), size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: AppMotion.press,
          width: selected ? 22 : 0,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B00),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
    return Pressable(onPressed: onTap, child: content);
  }
}
