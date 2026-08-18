import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:puzzle_match/ui/motion.dart';

class CompletionOverlay extends StatelessWidget {
  const CompletionOverlay({
    super.key,
    required this.image,
    required this.level,
    required this.stage,
    required this.remaining,
    required this.hints,
    required this.levelComplete,
    required this.onNext,
    required this.onHome,
    required this.onBack,
  });

  final ui.Image image;
  final int level;
  final int stage;
  final Duration remaining;
  final int hints;
  final bool levelComplete;
  final VoidCallback onNext;
  final VoidCallback onHome;
  final VoidCallback onBack;

  static const cream = Color(0xFFFFF3D6);
  static const creamDeep = Color(0xFFF6D9A0);
  static const titleBrown = Color(0xFF4A2A12);
  static const rewardFill = Color(0xFFF4DCB0);
  static const gold = Color(0xFFFFC107);
  static const goldDeep = Color(0xFFE65100);
  static const nextTop = Color(0xFFFFC107);
  static const nextMid = Color(0xFFFF9800);
  static const nextBottom = Color(0xFFEF6C00);

  @override
  Widget build(BuildContext context) {
    final seconds = remaining.inSeconds.clamp(0, 9999);
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    final title = levelComplete ? 'LEVEL COMPLETE!' : 'STAGE COMPLETE!';
    final nextLabel = levelComplete ? 'NEXT LEVEL' : 'NEXT STAGE';

    return Stack(
      fit: StackFit.expand,
      children: [
        RawImage(image: image, fit: BoxFit.cover, filterQuality: FilterQuality.high),
        const ColoredBox(color: Color(0x8A000000)),
        const IgnorePointer(child: _ConfettiLayer()),
        SafeArea(
          child: Column(
            children: [
              _CompleteHeader(
                level: level,
                stage: stage,
                time: '$mm:$ss',
                onBack: onBack,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      _CompleteCard(title: title),
                      const SizedBox(height: 22),
                      _GradientActionButton(
                        label: nextLabel,
                        onPressed: onNext,
                      ),
                      const SizedBox(height: 12),
                      _HomeActionButton(onPressed: onHome),
                    ],
                  ),
                ),
              ),
              _CompleteHint(hints: hints),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompleteHeader extends StatelessWidget {
  const _CompleteHeader({
    required this.level,
    required this.stage,
    required this.time,
    required this.onBack,
  });

  final int level;
  final int stage;
  final String time;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 8, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'Level $level  •  Stage $stage',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const Icon(Icons.timer_outlined, color: Color(0xFFFFC107), size: 20),
          const SizedBox(width: 4),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: null,
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.6),
              ),
              child: const Icon(Icons.pause_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteCard extends StatelessWidget {
  const _CompleteCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 48),
          padding: const EdgeInsets.fromLTRB(18, 58, 18, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF6DD),
                Color(0xFFF8DC9E),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.38),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'serif',
                  color: Color(0xFF4A2A12),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              const _StarDivider(),
              const SizedBox(height: 14),
              const _RewardRow(),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          child: _MedalBadge(),
        ),
      ],
    );
  }
}

class _StarDivider extends StatelessWidget {
  const _StarDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1.2, color: const Color(0xFF8D6E4A)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.star_rounded, size: 14, color: Color(0xFF6D4C41)),
        ),
        Expanded(
          child: Container(height: 1.2, color: const Color(0xFF8D6E4A)),
        ),
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3DCB4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Expanded(
              child: _RewardItem(
              icon: _CoinGlyph(),
              value: '+100',
              label: 'Coins',
            ),
          ),
          SizedBox(
            height: 36,
            child: VerticalDivider(
              width: 20,
              thickness: 1,
              color: Color(0xFFC8A882),
            ),
          ),
          Expanded(
            child: _RewardItem(
              icon: _HintGlyph(),
              value: '+1',
              label: 'Hint',
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  const _RewardItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final Widget icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF3E2723),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6D4C41),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CoinGlyph extends StatelessWidget {
  const _CoinGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE082), Color(0xFFFF8F00)],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: const Center(
        child: Text(
          '\$',
          style: TextStyle(
            color: Color(0xFF5D3A00),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _HintGlyph extends StatelessWidget {
  const _HintGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF6A1B9A),
        boxShadow: [
          BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFD54F), size: 22),
    );
  }
}

class _MedalBadge extends StatelessWidget {
  const _MedalBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 104,
      child: CustomPaint(painter: _MedalPainter()),
    );
  }
}

class _MedalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);
    canvas.drawCircle(
      center,
      52,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          56,
          [const Color(0xCCFFFFFF), const Color(0x00FFFFFF)],
        ),
    );
    _laurel(canvas, center, true);
    _laurel(canvas, center, false);
    canvas.drawCircle(
      center,
      30,
      Paint()
        ..shader = ui.Gradient.linear(
          center.translate(-16, -16),
          center.translate(18, 20),
          const [Color(0xFFFFF59D), Color(0xFFFFC107), Color(0xFFF57F17)],
        ),
    );
    canvas.drawCircle(
      center,
      30,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFECB3),
    );
    final star = Path();
    const r = 13.0;
    const inner = 5.5;
    for (var i = 0; i < 5; i++) {
      final outerA = -pi / 2 + i * 2 * pi / 5;
      final innerA = outerA + pi / 5;
      final op = center + Offset(cos(outerA) * r, sin(outerA) * r);
      final ip = center + Offset(cos(innerA) * inner, sin(innerA) * inner);
      if (i == 0) {
        star.moveTo(op.dx, op.dy);
      } else {
        star.lineTo(op.dx, op.dy);
      }
      star.lineTo(ip.dx, ip.dy);
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFF8D6E00));
  }

  void _laurel(Canvas canvas, Offset center, bool left) {
    final paint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final dir = left ? -1.0 : 1.0;
    final path = Path()
      ..moveTo(center.dx + dir * 34, center.dy + 18)
      ..quadraticBezierTo(
        center.dx + dir * 58,
        center.dy,
        center.dx + dir * 36,
        center.dy - 28,
      );
    canvas.drawPath(path, paint);
    for (var i = 0; i < 5; i++) {
      final t = 0.15 + i * 0.18;
      final p = Offset(
        center.dx + dir * (34 + 10 * sin(t * pi)),
        center.dy + 18 - t * 46,
      );
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 10, height: 6),
        Paint()..color = Color.lerp(const Color(0xFFFFE082), const Color(0xFFFF8F00), i / 5)!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({required this.label, required this.onPressed});

  final String label;
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
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFD54F),
                Color(0xFFFF9800),
                Color(0xFFEF6C00),
              ],
              stops: [0, 0.45, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5D2C00).withValues(alpha: 0.55),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 10,
                right: 10,
                top: 3,
                height: 22,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.22),
                        border: Border.all(color: Colors.white, width: 1.4),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({required this.onPressed});

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
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, color: Color(0xFFFFC107), size: 22),
              SizedBox(width: 8),
              Text(
                'HOME',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompleteHint extends StatelessWidget {
  const _CompleteHint({required this.hints});

  final int hints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A1038),
                border: Border.all(color: const Color(0xFFAB47BC), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B1FA2).withValues(alpha: 0.55),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFFFFD54F),
                size: 36,
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF8E24AA),
                child: Text(
                  '$hints',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiLayer extends StatelessWidget {
  const _ConfettiLayer();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _ConfettiPainter(), size: Size.infinite);
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter();

  static const colors = [
    Color(0xFF4FC3F7),
    Color(0xFFF48FB1),
    Color(0xFFFFF176),
    Color(0xFF81C784),
    Color(0xFFFF8A65),
    Color(0xFFBA68C8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(18);
    for (var i = 0; i < 46; i++) {
      final origin = Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height);
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.rotate(rng.nextDouble() * pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 6 + rng.nextDouble() * 10,
            height: 3 + rng.nextDouble() * 5,
          ),
          const Radius.circular(1),
        ),
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.9),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
