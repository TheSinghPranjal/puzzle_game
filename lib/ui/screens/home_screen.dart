import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle_match/models/puzzle_image_ref.dart';
import 'package:puzzle_match/services/image_repository.dart';
import 'package:puzzle_match/state/app_controller.dart';
import 'package:puzzle_match/theme/app_theme.dart';
import 'package:puzzle_match/ui/motion.dart';
import 'package:puzzle_match/ui/screens/game_screen.dart';
import 'package:puzzle_match/ui/screens/levels_screen.dart';
import 'package:puzzle_match/ui/screens/profile_screen.dart';
import 'package:puzzle_match/ui/screens/settings_screen.dart';
import 'package:puzzle_match/ui/widgets/puzzle_thumb.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const cream = Color(0xFFF0E9D7);
  static const brown = Color(0xFF4A3B2A);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final profile = app.profile;
    final resumeLevel = profile.canResume ? profile.resumeLevel : 1;
    final resumeStage = profile.canResume ? profile.resumeStage : 1;
    final preview = _previewImage(app, resumeLevel, resumeStage);

    final colors = context.puzzleColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.12),
            radius: 1.2,
            colors: [colors.backgroundMid, colors.background, colors.backgroundEdge],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _TopBar(
                  coins: profile.coins,
                  hints: profile.hintPoints,
                  onSettings: () =>
                      AppMotion.open(context, const SettingsScreen()),
                ),
              ),
              const SizedBox(height: 18),
              const _TitleBlock(),
              const SizedBox(height: 10),
              Text(
                '${profile.emoji}  ${profile.name}',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: _PreviewCard(
                    image: preview,
                    repository: app.images,
                    label: 'Level $resumeLevel  •  Stage $resumeStage',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _ResumeButton(
                  label: profile.canResume ? 'RESUME' : 'PLAY',
                  onPressed: () =>
                      _start(context, app, resume: profile.canResume),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _NewGameButton(
                  onPressed: () => _start(context, app, resume: false),
                ),
              ),
              const SizedBox(height: 10),
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
    final colors = context.puzzleColors;
    return Row(
      children: [
        _StatPill(leading: const _GoldCoin(size: 18), value: '$coins'),
        const SizedBox(width: 8),
        _StatPill(
          leading: Icon(
            Icons.lightbulb_rounded,
            color: const Color(0xFFFFD54F),
            size: 18,
            shadows: [
              Shadow(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.7),
                blurRadius: 8,
              ),
            ],
          ),
          value: '$hints',
        ),
        const Spacer(),
        Pressable(
          onPressed: onSettings,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.chrome,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.chromeBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.settings_rounded,
              color: colors.iconOnChrome,
              size: 22,
            ),
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
    final colors = context.puzzleColors;
    return Container(
      height: 36,
      padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
      decoration: BoxDecoration(
        color: colors.pillFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x55C9B27A), width: 1),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF59D), Color(0xFFFFC107), Color(0xFFF57F17)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.45),
            blurRadius: 4,
          ),
        ],
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

  static const _style = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.1,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.puzzleColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ExtrudedWord(
          'IMAGE',
          style: _style,
          depthColor: colors.titleDepth,
          face: Text(
            'IMAGE',
            style: _style.copyWith(color: colors.titleFace),
          ),
        ),
        const SizedBox(width: 10),
        const _ExtrudedWord(
          'PUZZLE',
          style: _style,
          depthColor: Color(0xFF8A3200),
          face: _GradientFace(text: 'PUZZLE', style: _style),
        ),
      ],
    );
  }
}

class _GradientFace extends StatelessWidget {
  const _GradientFace({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFE566),
          Color(0xFFFFB300),
          Color(0xFFFF6A00),
        ],
      ).createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class _ExtrudedWord extends StatelessWidget {
  const _ExtrudedWord(
    this.text, {
    required this.style,
    required this.depthColor,
    required this.face,
  });

  final String text;
  final TextStyle style;
  final Color depthColor;
  final Widget face;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = 5; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, i.toDouble()),
            child: Text(text, style: style.copyWith(color: depthColor)),
          ),
        Transform.translate(
          offset: const Offset(0, 6),
          child: Text(
            text,
            style: style.copyWith(
              color: Colors.transparent,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        face,
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
  final ImageRepository repository;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeScreen.cream,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE4D4B0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: PuzzleThumb(image: image, repository: repository),
            ),
          ),
          SizedBox(
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomPaint(
                  size: Size(26, 16),
                  painter: _WheatPainter(false),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: HomeScreen.brown,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const CustomPaint(
                  size: Size(26, 16),
                  painter: _WheatPainter(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WheatPainter extends CustomPainter {
  const _WheatPainter(this.mirror);

  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    if (mirror) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final stem = Paint()
      ..color = const Color(0xFFC4A574)
      ..strokeWidth = 1.35
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(1, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.08,
        size.width * 0.96,
        size.height * 0.42,
      );
    canvas.drawPath(path, stem);
    final leaf = Paint()..color = const Color(0xFFC4A574);
    const spots = [0.28, 0.48, 0.68, 0.84];
    for (var i = 0; i < spots.length; i++) {
      final t = spots[i];
      final x = size.width * t;
      final y = size.height * (0.72 - t * 0.42);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(-0.7);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 7.5, height: 3.2),
        leaf,
      );
      canvas.restore();
      canvas.save();
      canvas.translate(x + 1.5, y + 3.5);
      canvas.rotate(0.55);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 6.5, height: 2.8),
        leaf,
      );
      canvas.restore();
    }
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
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFC14A),
                    Color(0xFFFF9800),
                    Color(0xFFFB8C00),
                    Color(0xFFF57C00),
                  ],
                  stops: [0, 0.28, 0.62, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.55),
                    blurRadius: 18,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 14,
                    right: 14,
                    top: 3,
                    height: 18,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.42),
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
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1.4,
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
        const Positioned(left: 22, top: -5, child: _Sparkle()),
        const Positioned(right: 28, top: -3, child: _Sparkle(small: true)),
        const Positioned(right: 10, bottom: 6, child: _Sparkle(small: true)),
        const Positioned(left: 48, bottom: -4, child: _Sparkle()),
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
      ..strokeWidth = 1.25
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
            color: context.puzzleColors.outlineFill,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFF6B00), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _GradientIcon(icon: Icons.extension_rounded, size: 22),
              const SizedBox(width: 8),
              Text(
                'NEW GAME',
                style: TextStyle(
                  color: context.puzzleColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientIcon extends StatelessWidget {
  const _GradientIcon({required this.icon, this.size = 24});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
      ).createShader(bounds),
      child: Icon(icon, size: size, color: Colors.white),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        decoration: BoxDecoration(
          color: context.puzzleColors.navBar,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _NavTab(
                icon: Icons.person_rounded,
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
    final iconWidget = _GradientIcon(icon: icon, size: selected ? 26 : 24);
    return Pressable(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: selected ? 52 : 40,
            height: selected ? 44 : 36,
            alignment: Alignment.center,
            decoration: selected
                ? BoxDecoration(
                    color: context.puzzleColors.navTile,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B00).withValues(alpha: 0.22),
                        blurRadius: 10,
                      ),
                    ],
                  )
                : null,
            child: selected
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 1,
                        left: 8,
                        right: 8,
                        height: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.28),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      iconWidget,
                    ],
                  )
                : iconWidget,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: context.puzzleColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 5),
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
      ),
    );
  }
}
