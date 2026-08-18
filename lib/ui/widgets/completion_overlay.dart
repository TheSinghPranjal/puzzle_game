import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:puzzle_match/ui/motion.dart';

class CompletionOverlay extends StatefulWidget {
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

  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _confetti;
  late final Animation<double> _dim;
  late final Animation<double> _card;
  late final Animation<double> _next;
  late final Animation<double> _home;
  late final Animation<double> _hint;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _dim = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0, 0.32, curve: Curves.easeOut),
    );
    _card = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.08, 0.58, curve: Curves.easeOutBack),
    );
    _next = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.32, 0.76, curve: Curves.easeOutCubic),
    );
    _home = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.42, 0.88, curve: Curves.easeOutCubic),
    );
    _hint = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.52, 1, curve: Curves.easeOut),
    );
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = widget.remaining.inSeconds.clamp(0, 9999);
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    final title = widget.levelComplete ? 'LEVEL COMPLETE!' : 'STAGE COMPLETE!';
    final nextLabel = widget.levelComplete ? 'NEXT LEVEL' : 'NEXT STAGE';

    return Stack(
      fit: StackFit.expand,
      children: [
        RawImage(
          image: widget.image,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
        FadeTransition(
          opacity: _dim,
          child: const ColoredBox(color: Color(0x59000000)),
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _confetti,
            builder: (context, _) => CustomPaint(
              painter: _ConfettiPainter(_confetti.value),
              size: Size.infinite,
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _CompleteHeader(
                level: widget.level,
                stage: widget.stage,
                time: '$mm:$ss',
                onBack: widget.onBack,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 16,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FadeScale(
                              animation: _card,
                              child: _CompleteCard(title: title),
                            ),
                            const SizedBox(height: 22),
                            _FadeSlide(
                              animation: _next,
                              child: _GradientActionButton(
                                label: nextLabel,
                                onPressed: widget.onNext,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _FadeSlide(
                              animation: _home,
                              child: _HomeActionButton(onPressed: widget.onHome),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              FadeTransition(
                opacity: _hint,
                child: _CompleteHint(hints: widget.hints),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FadeScale extends StatelessWidget {
  const _FadeScale({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.84, end: 1).animate(animation),
        child: child,
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.22),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
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
          margin: const EdgeInsets.only(top: 44),
          padding: const EdgeInsets.fromLTRB(18, 56, 18, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3D6),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 24,
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
                  color: Color(0xFF4A2A12),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
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
    return const Row(
      children: [
        Expanded(child: Divider(height: 1, thickness: 1.2, color: Color(0xFF8D6E4A))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.star_rounded, size: 14, color: Color(0xFF6D4C41)),
        ),
        Expanded(child: Divider(height: 1, thickness: 1.2, color: Color(0xFF8D6E4A))),
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
    return const SizedBox(
      width: 168,
      height: 112,
      child: CustomPaint(painter: _MedalPainter()),
    );
  }
}

class _MedalPainter extends CustomPainter {
  const _MedalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);
    canvas.drawCircle(
      center,
      58,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          58,
          [const Color(0xE6FFFFFF), const Color(0x00FFFFFF)],
        ),
    );
    _laurel(canvas, center, true);
    _laurel(canvas, center, false);
  }

  void _laurel(Canvas canvas, Offset center, bool left) {
    final paint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final dir = left ? -1.0 : 1.0;
    final path = Path()
      ..moveTo(center.dx + dir * 34, center.dy + 20)
      ..quadraticBezierTo(
        center.dx + dir * 62,
        center.dy,
        center.dx + dir * 34,
        center.dy - 32,
      );
    canvas.drawPath(path, paint);
    for (var i = 0; i < 6; i++) {
      final t = 0.12 + i * 0.15;
      final p = Offset(
        center.dx + dir * (34 + 12 * sin(t * pi)),
        center.dy + 20 - t * 52,
      );
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 11, height: 6.5),
        Paint()
          ..color = Color.lerp(const Color(0xFFFFE082), const Color(0xFFFF8F00), i / 6)!,
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
                color: const Color(0xFF5D2C00).withValues(alpha: 0.5),
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
                        Colors.white.withValues(alpha: 0.4),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFFFB300),
                      size: 22,
                    ),
                  ),
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
                color: Colors.black.withValues(alpha: 0.45),
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

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter(this.t);

  final double t;

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
    if (size.isEmpty) return;
    final rng = Random(18);
    for (var i = 0; i < 52; i++) {
      final speed = 0.35 + rng.nextDouble() * 0.9;
      final x = rng.nextDouble() * size.width;
      final start = rng.nextDouble();
      final y = ((start + t * speed) % 1.0) * (size.height + 28) - 14;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((rng.nextDouble() + t) * pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 6 + rng.nextDouble() * 10,
            height: 3 + rng.nextDouble() * 5,
          ),
          const Radius.circular(1.2),
        ),
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.92),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
