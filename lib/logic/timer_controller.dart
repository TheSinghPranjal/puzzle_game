import 'package:flutter/scheduler.dart';

typedef TimerExpiredCallback = void Function();
typedef TimerTickCallback = void Function(Duration remaining);

class GameTimerController {
  GameTimerController({
    required Duration duration,
    this.onTick,
    this.onExpired,
  }) : remaining = duration,
       _total = duration;

  final TimerTickCallback? onTick;
  final TimerExpiredCallback? onExpired;

  Duration remaining;
  final Duration _total;
  DateTime? _deadline;
  Ticker? _ticker;
  bool _expired = false;
  bool paused = true;

  Duration get total => _total;
  bool get isRunning => !paused && _deadline != null && !_expired;
  bool get isExpired => _expired || remaining <= Duration.zero;

  void attachTicker(TickerProvider vsync) {
    if (_ticker != null) return;
    _ticker = vsync.createTicker(_handleTick);
  }

  void start() {
    if (_expired) return;
    paused = false;
    _deadline = DateTime.now().add(remaining);
    _ticker?.start();
    onTick?.call(remaining);
  }

  void pause() {
    if (paused || _expired) return;
    _syncRemaining();
    paused = true;
    _deadline = null;
    _ticker?.stop();
    onTick?.call(remaining);
  }

  void resume() {
    if (!paused || _expired || remaining <= Duration.zero) return;
    start();
  }

  void stop() {
    paused = true;
    _deadline = null;
    _ticker?.stop();
  }

  void restoreRemaining(Duration value) {
    remaining = value < Duration.zero ? Duration.zero : value;
    if (remaining <= Duration.zero) {
      _expire();
    }
  }

  void dispose() {
    _ticker?.dispose();
    _ticker = null;
  }

  Duration? _lastEmitted;

  void _handleTick(Duration _) {
    if (paused || _deadline == null) return;
    _syncRemaining();
    final secondsChanged =
        _lastEmitted == null || remaining.inSeconds != _lastEmitted!.inSeconds;
    if (secondsChanged) {
      _lastEmitted = remaining;
      onTick?.call(remaining);
    }
    if (remaining <= Duration.zero) {
      _expire();
    }
  }

  void _syncRemaining() {
    if (_deadline == null) return;
    remaining = _deadline!.difference(DateTime.now());
    if (remaining.isNegative) remaining = Duration.zero;
  }

  void _expire() {
    if (_expired) return;
    _expired = true;
    remaining = Duration.zero;
    paused = true;
    _deadline = null;
    _ticker?.stop();
    onExpired?.call();
  }
}
