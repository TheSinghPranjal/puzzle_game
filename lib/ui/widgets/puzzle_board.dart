import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:puzzle_match/logic/puzzle_engine.dart';
import 'package:puzzle_match/theme/app_theme.dart';

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

class _PuzzleBoardState extends State<PuzzleBoard> {
  int? _grabbedIndex;
  int? _hoverIndex;
  Offset _pointer = Offset.zero;
  Offset _grabLocal = Offset.zero;
  bool _dragging = false;

  PuzzleEngine get _engine => widget.engine;

  @override
  void didUpdateWidget(covariant PuzzleBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.interactive && (_dragging || _grabbedIndex != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cancelDrag();
      });
    }
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
            onPointerDown: widget.interactive && widget.dragEnabled
                ? (event) => _onDown(event.localPosition, tileSize)
                : null,
            onPointerMove: widget.interactive && widget.dragEnabled
                ? (event) => _onMove(event.localPosition, tileSize)
                : null,
            onPointerUp: widget.interactive && widget.dragEnabled
                ? (event) => _onUp(event.localPosition, tileSize)
                : null,
            onPointerCancel: widget.interactive
                ? (_) => _cancelDrag()
                : null,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BoardPainter(
                      engine: _engine,
                      image: widget.image,
                      hidden: _dragging ? _draggedPositions() : const {},
                      highlightIndex: widget.highlightIndex,
                      hoverIndex: _dragging ? _hoverIndex : null,
                      debugMode: widget.debugMode,
                    ),
                  ),
                ),
                if (_dragging && _grabbedIndex != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _DragPainter(
                          engine: _engine,
                          image: widget.image,
                          positions: _draggedPositions(),
                          offset: _pointer - _grabLocal,
                        ),
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

  Set<int> _draggedPositions() {
    if (_grabbedIndex == null) return {};
    return _engine.groupAt(_grabbedIndex!).positions;
  }

  void _onDown(Offset local, Size tileSize) {
    final index = _indexFor(local, tileSize);
    if (index == null) return;
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
    _cancelDrag();
    if (!wasDragging || grabbed == null || hover == null) return;
    final result = _engine.moveGroup(grabbedIndex: grabbed, dropIndex: hover);
    if (result.applied) {
      widget.onMoved(result);
      setState(() {});
    }
  }

  void _cancelDrag() {
    if (_grabbedIndex == null && !_dragging) return;
    setState(() {
      _grabbedIndex = null;
      _hoverIndex = null;
      _dragging = false;
    });
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
  });

  final PuzzleEngine engine;
  final ui.Image image;
  final Set<int> hidden;
  final int? highlightIndex;
  final int? hoverIndex;
  final bool debugMode;

  @override
  void paint(Canvas canvas, Size size) {
    final imagePaint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;

    for (var index = 0; index < engine.tileCount; index++) {
      if (hidden.contains(index)) continue;
      final dest = _destRect(index, engine.rows, engine.columns, size);
      final src = _srcRect(engine.tileIdAt(index), engine.rows, engine.columns, image);
      canvas.drawImageRect(image, src, dest, imagePaint);
      _drawSeparators(canvas, index, dest);
      if (highlightIndex == index) {
        canvas.drawRect(
          dest,
          Paint()
            ..color = AppTheme.hint.withValues(alpha: 0.28)
            ..style = PaintingStyle.fill,
        );
      }
      if (hoverIndex != null &&
          engine.groupAt(hoverIndex!).contains(index) &&
          hidden.isNotEmpty) {
        canvas.drawRect(
          dest,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.12)
            ..style = PaintingStyle.fill,
        );
      }
      if (debugMode) {
        _debugLabel(canvas, dest, index);
      }
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

  void _debugLabel(Canvas canvas, Rect dest, int index) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: 10, fontWeight: FontWeight.bold),
    )
      ..pushStyle(ui.TextStyle(color: Colors.white))
      ..addText(
        't${engine.tileIdAt(index)}\np$index g${engine.groupAt(index).id}',
      );
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

class _DragPainter extends CustomPainter {
  _DragPainter({
    required this.engine,
    required this.image,
    required this.positions,
    required this.offset,
  });

  final PuzzleEngine engine;
  final ui.Image image;
  final Set<int> positions;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final imagePaint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;

    for (final index in positions) {
      final dest = _destRect(index, engine.rows, engine.columns, size).inflate(1.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(dest.translate(0, 4), const Radius.circular(2)),
        shadow,
      );
      final src = _srcRect(engine.tileIdAt(index), engine.rows, engine.columns, image);
      canvas.drawImageRect(image, src, dest, imagePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DragPainter oldDelegate) => true;
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
