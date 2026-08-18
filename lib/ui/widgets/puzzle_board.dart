import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puzzle_match/logic/puzzle_engine.dart';
import 'package:puzzle_match/theme/app_theme.dart';
import 'package:puzzle_match/ui/motion.dart';

class PuzzleBoard extends StatefulWidget {
  const PuzzleBoard({
    super.key,
    required this.engine,
    required this.image,
    required this.interactive,
    required this.debugMode,
    required this.onMoved,
    this.highlightIndex,
    this.dragEnabled = true,
  });

  final PuzzleEngine engine;
  final ui.Image image;
  final bool interactive;
  final bool debugMode;
  final ValueChanged<MoveResult> onMoved;
  final int? highlightIndex;
  final bool dragEnabled;

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard>
    with TickerProviderStateMixin {
  late final AnimationController _lift;
  late final AnimationController _settle;

  int? _grabbedIndex;
  int? _hoverIndex;
  Offset _pointer = Offset.zero;
  Offset _grabLocal = Offset.zero;
  Offset _dragOffset = Offset.zero;
  bool _dragging = false;

  List<int> _shownPlacement = const [];
  Map<int, int> _fromIndexByTile = {};
  Map<int, int> _toIndexByTile = {};
  Set<int> _liftedTileIds = {};

  PuzzleEngine get _engine => widget.engine;
  bool get _settling => _settle.isAnimating;

  @override
  void initState() {
    super.initState();
    _shownPlacement = List<int>.from(_engine.placement);
    _lift = AnimationController(vsync: this, duration: AppMotion.lift);
    _settle = AnimationController(vsync: this, duration: AppMotion.settle)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shownPlacement = List<int>.from(_engine.placement);
          _fromIndexByTile = {};
          _toIndexByTile = {};
          _liftedTileIds = {};
          _dragOffset = Offset.zero;
          _settle.reset();
          setState(() {});
        }
      });
    _lift.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant PuzzleBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.interactive && (_dragging || _grabbedIndex != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cancelDrag(animate: false);
      });
    }
    if (!identical(oldWidget.engine, widget.engine)) {
      _shownPlacement = List<int>.from(_engine.placement);
      _settle.stop();
      _settle.reset();
      return;
    }
    _maybeAnimateExternalMove();
  }

  @override
  void dispose() {
    _lift.dispose();
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final tileSize = Size(
          size.width / _engine.columns,
          size.height / _engine.rows,
        );
        return ClipRect(
          child: Listener(
            onPointerDown: widget.interactive &&
                    widget.dragEnabled &&
                    !_settling
                ? (event) => _onDown(event.localPosition, tileSize)
                : null,
            onPointerMove: widget.interactive &&
                    widget.dragEnabled &&
                    !_settling
                ? (event) => _onMove(event.localPosition, tileSize)
                : null,
            onPointerUp: widget.interactive && widget.dragEnabled && !_settling
                ? (event) => _onUp(event.localPosition, tileSize)
                : null,
            onPointerCancel: widget.interactive
                ? (_) => _cancelDrag(animate: true)
                : null,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BoardPainter(
                      engine: _engine,
                      image: widget.image,
                      hidden: _hiddenPositions(),
                      highlightIndex: widget.highlightIndex,
                      hoverIndex: _dragging ? _hoverIndex : null,
                      debugMode: widget.debugMode,
                      settleValue: AppMotion.easeOut.transform(_settle.value),
                      fromIndexByTile: _fromIndexByTile,
                      toIndexByTile: _toIndexByTile,
                      liftedTileIds: _liftedTileIds,
                      dragOffset: _dragging ? _pointer - _grabLocal : _dragOffset,
                      liftValue: _lift.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Set<int> _hiddenPositions() {
    if (_settling) return {};
    if (_grabbedIndex == null) return {};
    return _engine.groupAt(_grabbedIndex!).positions;
  }

  void _onDown(Offset local, Size tileSize) {
    final index = _indexFor(local, tileSize);
    if (index == null) return;
    HapticFeedback.selectionClick();
    _lift.forward(from: 0);
    setState(() {
      _grabbedIndex = index;
      _pointer = local;
      _grabLocal = local;
      _hoverIndex = index;
      _dragging = false;
    });
  }

  void _onMove(Offset local, Size tileSize) {
    if (_grabbedIndex == null) return;
    final distance = (local - _grabLocal).distance;
    setState(() {
      _pointer = local;
      if (distance > 8) _dragging = true;
      _hoverIndex = _indexFor(local, tileSize);
    });
  }

  void _onUp(Offset local, Size tileSize) {
    final grabbed = _grabbedIndex;
    final hover = _indexFor(local, tileSize);
    final wasDragging = _dragging;
    final offset = local - _grabLocal;
    if (!wasDragging || grabbed == null) {
      _cancelDrag(animate: true);
      return;
    }
    if (hover == null) {
      _snapBack(offset);
      return;
    }
    final liftedIds = {
      for (final index in _engine.groupAt(grabbed).positions)
        _engine.tileIdAt(index),
    };
    final before = List<int>.from(_engine.placement);
    final result = _engine.moveGroup(grabbedIndex: grabbed, dropIndex: hover);
    if (!result.applied) {
      _snapBack(offset);
      return;
    }
    HapticFeedback.lightImpact();
    _startSettle(
      fromPlacement: before,
      toPlacement: _engine.placement,
      dragOffset: offset,
      liftedIds: liftedIds,
    );
    widget.onMoved(result);
  }

  void _snapBack(Offset offset) {
    _fromIndexByTile = {
      for (var i = 0; i < _shownPlacement.length; i++) _shownPlacement[i]: i,
    };
    _toIndexByTile = Map<int, int>.from(_fromIndexByTile);
    _liftedTileIds = _grabbedIndex == null
        ? {}
        : _engine.groupAt(_grabbedIndex!).positions
            .map((index) => _shownPlacement[index])
            .toSet();
    _dragOffset = offset;
    _grabbedIndex = null;
    _hoverIndex = null;
    _dragging = false;
    _lift.reverse();
    _settle.forward(from: 0);
  }

  void _startSettle({
    required List<int> fromPlacement,
    required List<int> toPlacement,
    required Offset dragOffset,
    required Set<int> liftedIds,
  }) {
    _fromIndexByTile = {
      for (var i = 0; i < fromPlacement.length; i++) fromPlacement[i]: i,
    };
    _toIndexByTile = {
      for (var i = 0; i < toPlacement.length; i++) toPlacement[i]: i,
    };
    _liftedTileIds = liftedIds;
    _dragOffset = dragOffset;
    _shownPlacement = List<int>.from(toPlacement);
    _grabbedIndex = null;
    _hoverIndex = null;
    _dragging = false;
    _lift.reverse();
    _settle.forward(from: 0);
  }

  void _maybeAnimateExternalMove() {
    if (_dragging || _settling) return;
    final current = _engine.placement;
    if (_samePlacement(current, _shownPlacement)) return;
    _startSettle(
      fromPlacement: _shownPlacement,
      toPlacement: current,
      dragOffset: Offset.zero,
      liftedIds: {},
    );
  }

  void _cancelDrag({required bool animate}) {
    if (_grabbedIndex == null && !_dragging) return;
    if (animate && _dragging) {
      _snapBack(_pointer - _grabLocal);
      return;
    }
    _lift.reverse();
    setState(() {
      _grabbedIndex = null;
      _hoverIndex = null;
      _dragging = false;
    });
  }

  bool _samePlacement(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int? _indexFor(Offset local, Size tileSize) {
    final col = (local.dx / tileSize.width).floor();
    final row = (local.dy / tileSize.height).floor();
    if (row < 0 || col < 0 || row >= _engine.rows || col >= _engine.columns) {
      return null;
    }
    return row * _engine.columns + col;
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.engine,
    required this.image,
    required this.hidden,
    required this.highlightIndex,
    required this.hoverIndex,
    required this.debugMode,
    required this.settleValue,
    required this.fromIndexByTile,
    required this.toIndexByTile,
    required this.liftedTileIds,
    required this.dragOffset,
    required this.liftValue,
  });

  final PuzzleEngine engine;
  final ui.Image image;
  final Set<int> hidden;
  final int? highlightIndex;
  final int? hoverIndex;
  final bool debugMode;
  final double settleValue;
  final Map<int, int> fromIndexByTile;
  final Map<int, int> toIndexByTile;
  final Set<int> liftedTileIds;
  final Offset dragOffset;
  final double liftValue;

  @override
  void paint(Canvas canvas, Size size) {
    final imagePaint = Paint()
      ..filterQuality = (liftValue > 0 || settleValue > 0)
          ? FilterQuality.medium
          : FilterQuality.high
      ..isAntiAlias = true;

    final settling = settleValue > 0 && settleValue < 1;
    if (settling) {
      _paintSettling(canvas, size, imagePaint);
      return;
    }

    for (var index = 0; index < engine.tileCount; index++) {
      if (hidden.contains(index)) continue;
      final dest = _destRect(index, engine.rows, engine.columns, size);
      _paintTile(canvas, imagePaint, engine.tileIdAt(index), dest, index);
    }

    if (hidden.isNotEmpty) {
      _paintLiftedGroup(canvas, size, imagePaint);
    }
  }

  void _paintSettling(Canvas canvas, Size size, Paint imagePaint) {
    final t = settleValue;
    for (var tileId = 0; tileId < engine.tileCount; tileId++) {
      final fromIndex = fromIndexByTile[tileId] ?? toIndexByTile[tileId] ?? tileId;
      final toIndex = toIndexByTile[tileId] ?? fromIndex;
      var fromRect = _destRect(fromIndex, engine.rows, engine.columns, size);
      final toRect = _destRect(toIndex, engine.rows, engine.columns, size);
      if (liftedTileIds.contains(tileId)) {
        fromRect = fromRect.shift(dragOffset);
      }
      final dest = Rect.lerp(fromRect, toRect, t)!;
      _paintTile(canvas, imagePaint, tileId, dest, toIndex, skipSeparators: t < 0.85);
    }
  }

  void _paintLiftedGroup(Canvas canvas, Size size, Paint imagePaint) {
    final scale = 1.0 + (0.055 * liftValue);
    final positions = hidden.toList()..sort();
    if (positions.isEmpty) return;
    var bounds = _destRect(positions.first, engine.rows, engine.columns, size);
    for (final index in positions.skip(1)) {
      bounds = bounds.expandToInclude(
        _destRect(index, engine.rows, engine.columns, size),
      );
    }
    final origin = bounds.center;
    canvas.save();
    canvas.translate(dragOffset.dx, dragOffset.dy);
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
    canvas.translate(-origin.dx, -origin.dy);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22 + 0.2 * liftValue)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + 6 * liftValue);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bounds.inflate(2).translate(0, 5),
        const Radius.circular(4),
      ),
      shadow,
    );
    for (final index in positions) {
      final dest = _destRect(index, engine.rows, engine.columns, size);
      _paintTile(
        canvas,
        imagePaint,
        engine.tileIdAt(index),
        dest,
        index,
        skipSeparators: true,
      );
    }
    canvas.restore();
  }

  void _paintTile(
    Canvas canvas,
    Paint imagePaint,
    int tileId,
    Rect dest,
    int index, {
    bool skipSeparators = false,
  }) {
    final src = _srcRect(tileId, engine.rows, engine.columns, image);
    canvas.drawImageRect(image, src, dest, imagePaint);
    if (!skipSeparators) {
      _drawSeparators(canvas, index, dest);
    }
    if (highlightIndex == index) {
      canvas.drawRect(
        dest,
        Paint()..color = AppTheme.hint.withValues(alpha: 0.28),
      );
    }
    if (hoverIndex != null &&
        engine.groupAt(hoverIndex!).contains(index) &&
        hidden.isNotEmpty) {
      canvas.drawRect(
        dest,
        Paint()..color = Colors.white.withValues(alpha: 0.14),
      );
    }
    if (debugMode) {
      _debugLabel(canvas, dest, index, tileId);
    }
  }

  void _drawSeparators(Canvas canvas, int index, Rect dest) {
    final paint = Paint()
      ..color = AppTheme.tileSeparator
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final col = index % engine.columns;
    final row = index ~/ engine.columns;
    if (col < engine.columns - 1) {
      final right = index + 1;
      if (!engine.isEdgeConnected(index, right)) {
        canvas.drawLine(dest.topRight, dest.bottomRight, paint);
      }
    }
    if (row < engine.rows - 1) {
      final below = index + engine.columns;
      if (!engine.isEdgeConnected(index, below)) {
        canvas.drawLine(dest.bottomLeft, dest.bottomRight, paint);
      }
    }
  }

  void _debugLabel(Canvas canvas, Rect dest, int index, int tileId) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: 10, fontWeight: FontWeight.bold),
    )
      ..pushStyle(ui.TextStyle(color: Colors.white))
      ..addText('t$tileId\np$index g${engine.groupAt(index).id}');
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: dest.width));
    canvas.drawRect(
      Rect.fromLTWH(dest.left, dest.top, dest.width, 28),
      Paint()..color = Colors.black54,
    );
    canvas.drawParagraph(paragraph, dest.topLeft);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}

Rect _destRect(int index, int rows, int columns, Size size) {
  final col = index % columns;
  final row = index ~/ columns;
  final left = col * size.width / columns;
  final right = (col + 1) * size.width / columns;
  final top = row * size.height / rows;
  final bottom = (row + 1) * size.height / rows;
  return Rect.fromLTRB(left, top, right, bottom);
}

Rect _srcRect(int tileId, int rows, int columns, ui.Image image) {
  final col = tileId % columns;
  final row = tileId ~/ columns;
  final left = (col * image.width / columns).roundToDouble();
  final right = ((col + 1) * image.width / columns).roundToDouble();
  final top = (row * image.height / rows).roundToDouble();
  final bottom = ((row + 1) * image.height / rows).roundToDouble();
  return Rect.fromLTRB(left, top, right, bottom);
}
