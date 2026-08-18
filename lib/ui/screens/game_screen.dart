import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle_match/models/puzzle_snapshot.dart';
import 'package:puzzle_match/state/app_controller.dart';
import 'package:puzzle_match/theme/app_theme.dart';
import 'package:puzzle_match/ui/motion.dart';
import 'package:puzzle_match/ui/widgets/completion_overlay.dart';
import 'package:puzzle_match/ui/widgets/game_controls.dart';
import 'package:puzzle_match/ui/widgets/puzzle_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int? _countdownValue;
  bool _countdownStarted = false;
  bool _hintAnimating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = context.read<AppController>();
    app.attachTicker(this);
    if (!_countdownStarted && app.phase == GamePhase.countdown) {
      _countdownStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _runCountdown();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<AppController>().handleAppLifecycle(state);
  }

  Future<void> _runCountdown() async {
    for (final value in [3, 2, 1]) {
      if (!mounted) return;
      setState(() => _countdownValue = value);
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }
    if (!mounted) return;
    setState(() => _countdownValue = 0);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _countdownValue = null);
    if (mounted) context.read<AppController>().beginPlay();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final engine = app.engine;
    final image = app.boardImage;
    final remaining = app.timer?.remaining ?? Duration.zero;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(app);
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _Header(
                    level: app.currentLevel,
                    stage: app.currentStage,
                    remaining: remaining,
                    onBack: () => _handleBack(app),
                    onPause: app.phase == GamePhase.playing
                        ? app.pauseGame
                        : null,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: engine == null || image == null
                            ? const CircularProgressIndicator()
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final aspect =
                                      image.width / image.height;
                                  var width = constraints.maxWidth;
                                  var height = width / aspect;
                                  if (height > constraints.maxHeight) {
                                    height = constraints.maxHeight;
                                    width = height * aspect;
                                  }
                                  return AnimatedSwitcher(
                                    duration: AppMotion.stage,
                                    switchInCurve: AppMotion.easeOut,
                                    switchOutCurve: AppMotion.easeIn,
                                    transitionBuilder: AppMotion.fadeSlide,
                                    child: SizedBox(
                                      key: ValueKey(
                                        '${app.currentLevel}-${app.currentStage}-${app.currentImage?.id}',
                                      ),
                                      width: width,
                                      height: height,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.35,
                                              ),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: PuzzleBoard(
                                            engine: engine,
                                            image: image,
                                            interactive: !app.boardLocked &&
                                                !_hintAnimating,
                                            debugMode: app.debugMode,
                                            highlightIndex: app.hintTo,
                                            onMoved: app.onBoardMoved,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  _HintBar(
                    hints: app.profile.hintPoints,
                    enabled: !app.boardLocked &&
                        app.hintsAvailable &&
                        !_hintAnimating,
                    onHint: () => _useHint(app),
                  ),
                ],
              ),
            ),
              AnimatedSwitcher(
                duration: AppMotion.overlay,
                switchInCurve: AppMotion.easeOut,
                switchOutCurve: AppMotion.easeIn,
                transitionBuilder: AppMotion.overlayTransition,
                child: _countdownValue != null
                    ? _CountdownScrim(
                        key: const ValueKey('countdown'),
                        label: _countdownValue == 0
                            ? 'SOLVE'
                            : '${_countdownValue!}',
                      )
                    : app.phase == GamePhase.paused
                    ? _PauseScrim(
                        key: const ValueKey('paused'),
                        onResume: app.resumePausedGame,
                        onHome: () => _goHome(app),
                      )
                    : app.phase == GamePhase.completed && image != null
                    ? CompletionOverlay(
                        key: const ValueKey('completed'),
                        image: image,
                        level: app.currentLevel,
                        stage: app.currentStage,
                        remaining: remaining,
                        hints: app.profile.hintPoints,
                        levelComplete: app.currentStage == 2 ||
                            app.config.nextStage(
                                  app.currentLevel,
                                  app.currentStage,
                                ) ==
                                null,
                        onNext: () => _afterWin(app),
                        onHome: () => _goHome(app),
                        onBack: () => _goHome(app),
                      )
                    : app.phase == GamePhase.failed
                    ? _ResultScrim(
                        key: const ValueKey('failed'),
                        title: "TIME'S UP!",
                        subtitle: 'No rewards this attempt',
                        primaryLabel: 'Retry',
                        onPrimary: () => _retry(app),
                        onHome: () => _goHome(app),
                      )
                    : const SizedBox.shrink(key: ValueKey('none')),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _useHint(AppController app) async {
    setState(() => _hintAnimating = true);
    await app.useHint();
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (mounted) setState(() => _hintAnimating = false);
  }

  void _handleBack(AppController app) {
    if (app.phase == GamePhase.countdown) {
      _goHome(app);
      return;
    }
    if (app.phase == GamePhase.playing) {
      app.pauseGame();
      return;
    }
    if (app.phase == GamePhase.paused) {
      app.resumePausedGame();
    }
  }

  Future<void> _goHome(AppController app) async {
    await app.leaveToHome();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _retry(AppController app) async {
    _countdownStarted = true;
    setState(() => _countdownValue = null);
    await app.retryStage();
    if (!mounted) return;
    _countdownStarted = true;
    _runCountdown();
  }

  Future<void> _afterWin(AppController app) async {
    final next = app.config.nextStage(app.currentLevel, app.currentStage);
    if (next == null) {
      await _goHome(app);
      return;
    }
    setState(() => _countdownValue = null);
    _countdownStarted = true;
    final error = await app.continueAfterWin();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    _runCountdown();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.level,
    required this.stage,
    required this.remaining,
    required this.onBack,
    required this.onPause,
  });

  final int level;
  final int stage;
  final Duration remaining;
  final VoidCallback onBack;
  final VoidCallback? onPause;

  @override
  Widget build(BuildContext context) {
    final seconds = remaining.inSeconds.clamp(0, 9999);
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    final urgent = seconds <= 10;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              'Level $level  •  Stage $stage',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          const Icon(Icons.timer_outlined, color: Color(0xFFFFC107), size: 20),
          const SizedBox(width: 4),
          AnimatedDefaultTextStyle(
            duration: AppMotion.overlay,
            curve: AppMotion.easeOut,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: urgent ? Colors.redAccent : Colors.white,
            ),
            child: Text('$mm:$ss'),
          ),
          IconButton(
            onPressed: onPause,
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 1.6),
              ),
              child: const Icon(Icons.pause_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBar extends StatelessWidget {
  const _HintBar({
    required this.hints,
    required this.enabled,
    required this.onHint,
  });

  final int hints;
  final bool enabled;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Center(
        child: Pressable(
          enabled: enabled,
          onPressed: enabled ? onHint : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: AppMotion.overlay,
                curve: AppMotion.easeOut,
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enabled ? AppTheme.hint : Colors.grey.shade700,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  size: 36,
                  color: enabled ? const Color(0xFF4E342E) : Colors.white54,
                ),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: AnimatedSwitcher(
                  duration: AppMotion.press,
                  child: CircleAvatar(
                    key: ValueKey(hints),
                    radius: 12,
                    backgroundColor:
                        enabled ? const Color(0xFF1E88E5) : Colors.blueGrey,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownScrim extends StatelessWidget {
  const _CountdownScrim({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: AnimatedSwitcher(
          duration: AppMotion.countdown,
          switchInCurve: AppMotion.spring,
          switchOutCurve: AppMotion.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.6, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            label,
            key: ValueKey(label),
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseScrim extends StatelessWidget {
  const _PauseScrim({
    super.key,
    required this.onResume,
    required this.onHome,
  });

  final VoidCallback onResume;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Paused',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 28),
                GameButton(label: 'Resume', onPressed: onResume),
                const SizedBox(height: 12),
                GameButton(label: 'Home', onPressed: onHome, primary: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultScrim extends StatelessWidget {
  const _ResultScrim({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onHome,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF5D4037),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6D4C41),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GameButton(label: primaryLabel, onPressed: onPrimary),
                const SizedBox(height: 12),
                GameButton(label: 'Home', onPressed: onHome, primary: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
