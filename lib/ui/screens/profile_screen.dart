import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle_match/models/profile.dart';
import 'package:puzzle_match/state/app_controller.dart';
import 'package:puzzle_match/ui/motion.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const navy = Color(0xFF0A0E17);
  static const navyMid = Color(0xFF121A26);
  static const card = Color(0xFF1C222E);
  static const gold = Color(0xFFFFB800);
  static const goldDeep = Color(0xFFFF8F00);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final selected = app.profile;

    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [navyMid, navy, Color(0xFF05070C)],
              ),
            ),
            child: SizedBox.expand(),
          ),
          const Positioned(
            top: 36,
            right: -18,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.07,
                child: Icon(Icons.pets_rounded, size: 168, color: Colors.white),
              ),
            ),
          ),
          const Positioned(
            top: 210,
            right: 72,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.04,
                child: Icon(Icons.pets_rounded, size: 72, color: Colors.white),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 180,
            child: IgnorePointer(child: CustomPaint(painter: _MountainPainter())),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _Header(onBack: () => Navigator.of(context).pop()),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    children: [
                      const _ChooseHeader(),
                      const SizedBox(height: 16),
                      _AvatarGrid(
                        profiles: app.profiles,
                        selectedId: app.selectedProfileId,
                        onSelect: app.selectProfile,
                      ),
                      const SizedBox(height: 22),
                      _SummaryCard(profile: selected),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: _UnlockBanner(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Pressable(
          onPressed: onBack,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1E232E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3A4652)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }
}

class _ChooseHeader extends StatelessWidget {
  const _ChooseHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Choose an avatar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 8),
            _Sparkle(size: 8, color: ProfileScreen.gold),
          ],
        ),
        SizedBox(height: 10),
        _PawDivider(),
      ],
    );
  }
}

class _PawDivider extends StatelessWidget {
  const _PawDivider();

  @override
  Widget build(BuildContext context) {
    Widget line() => Container(
          height: 1.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ProfileScreen.gold.withValues(alpha: 0.15),
                ProfileScreen.gold,
                ProfileScreen.gold.withValues(alpha: 0.15),
              ],
            ),
          ),
        );
    return Row(
      children: [
        const _Sparkle(size: 7, color: ProfileScreen.gold),
        const SizedBox(width: 6),
        Expanded(child: line()),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.pets_rounded, color: ProfileScreen.gold, size: 16),
        ),
        Expanded(child: line()),
        const SizedBox(width: 6),
        const _Sparkle(size: 7, color: ProfileScreen.gold),
      ],
    );
  }
}

class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({
    required this.profiles,
    required this.selectedId,
    required this.onSelect,
  });

  final List<PlayerProfile> profiles;
  final String selectedId;
  final Future<void> Function(String id) onSelect;

  @override
  Widget build(BuildContext context) {
    final top = profiles.take(3).toList();
    final bottom = profiles.skip(3).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final cardW = (constraints.maxWidth - gap * 2) / 3;
        Widget card(PlayerProfile profile) {
          return SizedBox(
            width: cardW,
            child: _AvatarCard(
              emoji: profile.emoji,
              name: profile.name,
              selected: profile.id == selectedId,
              onTap: () => onSelect(profile.id),
            ),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < top.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  card(top[i]),
                ],
              ],
            ),
            const SizedBox(height: gap),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < bottom.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  card(bottom[i]),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({
    required this.emoji,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: AppMotion.overlay,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
            decoration: BoxDecoration(
              color: ProfileScreen.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? ProfileScreen.gold : const Color(0xFF2E3644),
                width: selected ? 2.2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: ProfileScreen.gold.withValues(alpha: 0.42),
                        blurRadius: 14,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 38, height: 1)),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(
                    color: selected ? ProfileScreen.gold : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            const Positioned(
              top: -6,
              right: -6,
              child: _CheckBadge(),
            ),
        ],
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ProfileScreen.goldDeep,
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
        boxShadow: [
          BoxShadow(
            color: ProfileScreen.goldDeep.withValues(alpha: 0.5),
            blurRadius: 6,
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF0A0E17)),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final resume = profile.canResume
        ? 'Level ${profile.resumeLevel} · Stage ${profile.resumeStage}'
        : 'No game in progress';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2433), Color(0xFF121A26)],
        ),
        border: Border.all(color: const Color(0xFF3A4A5C), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _PortraitBadge(emoji: profile.emoji),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                _StatRow(
                  icon: const Icon(
                    Icons.workspace_premium_rounded,
                    color: ProfileScreen.gold,
                    size: 18,
                  ),
                  label: 'Highest:',
                  value:
                      'Level ${profile.highestLevel} · Stage ${profile.highestStage}',
                ),
                _StatRow(
                  icon: const _GoldCoin(size: 16),
                  label: 'Coins:',
                  value: '${profile.coins}',
                ),
                _StatRow(
                  icon: const Icon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFFFFD54F),
                    size: 18,
                  ),
                  label: 'Hints:',
                  value: '${profile.hintPoints}',
                ),
                _StatRow(
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                  label: 'Resume:',
                  value: resume,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitBadge extends StatelessWidget {
  const _PortraitBadge({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 114,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(56),
        border: Border.all(color: ProfileScreen.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: ProfileScreen.gold.withValues(alpha: 0.28),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(54),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _NightSkyPainter()),
            Center(
              child: Text(emoji, style: const TextStyle(fontSize: 42, height: 1)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final Widget icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              SizedBox(width: 22, child: Center(child: icon)),
              const SizedBox(width: 6),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$label ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: value,
                        style: const TextStyle(
                          color: Color(0xFFFFA000),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFF2A384D)),
      ],
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
          colors: [Color(0xFFFFF59D), Color(0xFFFFC107), Color(0xFFF57F17)],
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

class _UnlockBanner extends StatelessWidget {
  const _UnlockBanner();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xCC161C28),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x66D0D6DC)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets_rounded, color: Color(0xFFC48B7A), size: 16),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Play more to unlock new avatars!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB0B8C4),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          left: -4,
          top: 6,
          child: _Sparkle(size: 10, color: Color(0xFFFFE082)),
        ),
        const Positioned(
          right: -2,
          top: 4,
          child: _Sparkle(size: 10, color: Color(0xFFFFE082)),
        ),
        const Positioned(
          right: 14,
          bottom: -2,
          child: _Sparkle(size: 6, color: Color(0xFFFFE082)),
        ),
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
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

class _NightSkyPainter extends CustomPainter {
  const _NightSkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2740), Color(0xFF0B1220), Color(0xFF070A10)],
        ).createShader(rect),
    );
    final moon = Offset(size.width * 0.62, size.height * 0.28);
    canvas.drawCircle(moon, 11, Paint()..color = const Color(0x66FFF8E1));
    canvas.drawCircle(moon, 7.5, Paint()..color = const Color(0xFFFFF3C4));
    final tree = Paint()..color = const Color(0xFF0A1018);
    for (final x in [size.width * 0.18, size.width * 0.42, size.width * 0.78]) {
      final path = Path()
        ..moveTo(x, size.height * 0.42)
        ..lineTo(x - 16, size.height)
        ..lineTo(x + 16, size.height)
        ..close();
      canvas.drawPath(path, tree);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MountainPainter extends CustomPainter {
  const _MountainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.58)
      ..lineTo(size.width * 0.22, size.height * 0.18)
      ..lineTo(size.width * 0.4, size.height * 0.48)
      ..lineTo(size.width * 0.62, size.height * 0.12)
      ..lineTo(size.width * 0.82, size.height * 0.42)
      ..lineTo(size.width, size.height * 0.28)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF101820));
    final mid = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.72)
      ..lineTo(size.width * 0.18, size.height * 0.46)
      ..lineTo(size.width * 0.38, size.height * 0.7)
      ..lineTo(size.width * 0.58, size.height * 0.4)
      ..lineTo(size.width * 0.8, size.height * 0.66)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(mid, Paint()..color = const Color(0xFF0B1218));
    final tree = Paint()..color = const Color(0xFF080E14);
    for (var i = 0; i < 9; i++) {
      final x = size.width * (0.06 + i * 0.11);
      final h = 28.0 + (i % 3) * 10;
      final path = Path()
        ..moveTo(x, size.height - 18 - h)
        ..lineTo(x - 11, size.height)
        ..lineTo(x + 11, size.height)
        ..close();
      canvas.drawPath(path, tree);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
