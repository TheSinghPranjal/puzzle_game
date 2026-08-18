import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BuiltinImageGenerator {
  const BuiltinImageGenerator();

  static const count = 10;
  static const width = 720;
  static const height = 1280;

  Future<ui.Image> render(int index) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());
    paintScene(canvas, size, index % count);
    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  void paintScene(Canvas canvas, Size size, int index) {
    switch (index % count) {
      case 0:
        _balloonValley(canvas, size);
      case 1:
        _sunsetMountains(canvas, size);
      case 2:
        _oceanCove(canvas, size);
      case 3:
        _forestPath(canvas, size);
      case 4:
        _nightCity(canvas, size);
      case 5:
        _desertDunes(canvas, size);
      case 6:
        _aurora(canvas, size);
      case 7:
        _blossomHill(canvas, size);
      case 8:
        _waterfall(canvas, size);
      default:
        _lavenderField(canvas, size);
    }
  }

  void _balloonValley(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFF7EC8E3), const Color(0xFFD6F0FF));
    _sun(canvas, Offset(size.width * 0.82, size.height * 0.12), 70);
    _hills(canvas, size, const [Color(0xFF2F6B3A), Color(0xFF4C8A3F), Color(0xFF6B9B45)]);
    _river(canvas, size, const Color(0xFF3FA7C9));
    _fields(canvas, size);
    _balloon(canvas, Offset(size.width * 0.48, size.height * 0.34), 210);
    _clouds(canvas, size, 0.18);
  }

  void _sunsetMountains(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFFFFB347), const Color(0xFF6B2D5C));
    _sun(canvas, Offset(size.width * 0.5, size.height * 0.38), 90, color: const Color(0xFFFFF1C1));
    _hills(canvas, size, const [Color(0xFF2B1B3D), Color(0xFF5A2A4F), Color(0xFF8C4A3A)]);
  }

  void _oceanCove(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFF9AD7F5), const Color(0xFFFFF4D6));
    _rectBand(canvas, size, 0.42, 1, const Color(0xFF1E8BB8), const Color(0xFF0E5F7A));
    _waves(canvas, size);
    _sun(canvas, Offset(size.width * 0.78, size.height * 0.16), 54);
  }

  void _forestPath(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFFB8E0A8), const Color(0xFFF6F0C8));
    _hills(canvas, size, const [Color(0xFF144226), Color(0xFF1F6A34), Color(0xFF3B8C45)]);
    final rng = Random(11);
    for (var i = 0; i < 18; i++) {
      _tree(
        canvas,
        Offset(rng.nextDouble() * size.width, size.height * (0.42 + rng.nextDouble() * 0.4)),
        40 + rng.nextDouble() * 70,
      );
    }
  }

  void _nightCity(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFF070B24), const Color(0xFF2A2158));
    _stars(canvas, size, 90);
    final rng = Random(21);
    for (var i = 0; i < 9; i++) {
      final left = i * size.width / 9 + 8;
      final top = size.height * (0.38 + rng.nextDouble() * 0.2);
      _building(canvas, Rect.fromLTWH(left, top, size.width / 10, size.height - top), rng);
    }
  }

  void _desertDunes(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFFFFD89A), const Color(0xFFFFF6DF));
    _sun(canvas, Offset(size.width * 0.7, size.height * 0.18), 80, color: const Color(0xFFFFF3B0));
    _hills(canvas, size, const [Color(0xFFC47A30), Color(0xFFE0A04A), Color(0xFFF3C56B)]);
  }

  void _aurora(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFF041226), const Color(0xFF16324F));
    _stars(canvas, size, 70);
    final shader = ui.Gradient.linear(
      Offset(0, size.height * 0.1),
      Offset(size.width, size.height * 0.55),
      const [
        Color(0x6640F0C0),
        Color(0x668B5CF6),
        Color(0x3300D4FF),
      ],
      const [0.0, 0.5, 1.0],
    );
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    _hills(canvas, size, const [Color(0xFF0B1C22), Color(0xFF16333C)]);
  }

  void _blossomHill(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFFAED9FF), const Color(0xFFFFE4F0));
    _hills(canvas, size, const [Color(0xFF6FAF6A), Color(0xFF8EC96A)]);
    final rng = Random(7);
    for (var i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, size.height * (0.35 + rng.nextDouble() * 0.5)),
        8 + rng.nextDouble() * 16,
        Paint()..color = Color.lerp(const Color(0xFFFF9AC8), const Color(0xFFFFD6E8), rng.nextDouble())!,
      );
    }
  }

  void _waterfall(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFF8EC5E8), const Color(0xFFE8F6FF));
    _hills(canvas, size, const [Color(0xFF1F5A36), Color(0xFF3E7A42)]);
    final fall = Path()
      ..moveTo(size.width * 0.42, size.height * 0.28)
      ..lineTo(size.width * 0.58, size.height * 0.28)
      ..lineTo(size.width * 0.62, size.height * 0.82)
      ..lineTo(size.width * 0.38, size.height * 0.82)
      ..close();
    canvas.drawPath(
      fall,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width * 0.5, size.height * 0.28),
          Offset(size.width * 0.5, size.height * 0.82),
          const [Color(0xFFE8F6FF), Color(0xFF7EC8E3)],
        ),
    );
  }

  void _lavenderField(Canvas canvas, Size size) {
    _sky(canvas, size, const Color(0xFF9AD0F5), const Color(0xFFFFF4C2));
    _sun(canvas, Offset(size.width * 0.8, size.height * 0.14), 60);
    _hills(canvas, size, const [Color(0xFF7B5EA7), Color(0xFF9B7BC4), Color(0xFFC9A7E8)]);
  }

  void _sky(Canvas canvas, Size size, Color top, Color bottom) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          [top, bottom],
        ),
    );
  }

  void _sun(Canvas canvas, Offset center, double radius, {Color color = const Color(0xFFFFF4A3)}) {
    canvas.drawCircle(center, radius, Paint()..color = color.withValues(alpha: 0.95));
    canvas.drawCircle(center, radius * 1.35, Paint()..color = color.withValues(alpha: 0.18));
  }

  void _hills(Canvas canvas, Size size, List<Color> colors) {
    for (var i = 0; i < colors.length; i++) {
      final startY = size.height * (0.42 + i * 0.12);
      final path = Path()..moveTo(0, startY);
      path.quadraticBezierTo(
        size.width * 0.25,
        startY - 80 + i * 12,
        size.width * 0.5,
        startY + 20,
      );
      path.quadraticBezierTo(
        size.width * 0.75,
        startY + 90,
        size.width,
        startY - 10,
      );
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, Paint()..color = colors[i]);
    }
  }

  void _river(Canvas canvas, Size size, Color color) {
    final path = Path()
      ..moveTo(size.width * 0.46, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.68,
        size.width * 0.38,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.94,
        size.width * 0.28,
        size.height,
      )
      ..lineTo(size.width * 0.48, size.height)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.9,
        size.width * 0.52,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.62,
        size.width * 0.58,
        size.height * 0.5,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _fields(Canvas canvas, Size size) {
    final rng = Random(3);
    for (var i = 0; i < 8; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rng.nextDouble() * size.width * 0.7,
            size.height * (0.62 + rng.nextDouble() * 0.28),
            70 + rng.nextDouble() * 90,
            28 + rng.nextDouble() * 18,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = Color.lerp(const Color(0xFF8B5A2B), const Color(0xFFC4A35A), rng.nextDouble())!.withValues(alpha: 0.7),
      );
    }
  }

  void _balloon(Canvas canvas, Offset center, double size) {
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFFFB8C00),
      const Color(0xFFFDD835),
      const Color(0xFF43A047),
      const Color(0xFF1E88E5),
      const Color(0xFF8E24AA),
    ];
    final rect = Rect.fromCenter(center: center, width: size * 0.72, height: size);
    for (var i = 0; i < colors.length; i++) {
      final path = Path();
      final start = i / colors.length;
      final end = (i + 1) / colors.length;
      path.moveTo(rect.center.dx, rect.top);
      path.arcTo(rect, pi * (1.5 + start) - 0.08, (end - start) * pi + 0.04, false);
      path.lineTo(rect.center.dx, rect.bottom);
      path.close();
      canvas.drawPath(path, Paint()..color = colors[i]);
    }
    canvas.drawOval(rect.deflate(2), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.4));
    final basket = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size * 0.62),
      width: size * 0.16,
      height: size * 0.12,
    );
    canvas.drawLine(
      Offset(rect.center.dx - 18, rect.bottom - 8),
      basket.topLeft,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(rect.center.dx + 18, rect.bottom - 8),
      basket.topRight,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(basket, const Radius.circular(4)),
      Paint()..color = const Color(0xFF8D6E63),
    );
  }

  void _clouds(Canvas canvas, Size size, double yFactor) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.82);
    void cloud(Offset c, double s) {
      canvas.drawCircle(c, s, paint);
      canvas.drawCircle(c + Offset(s * 0.8, 8), s * 0.75, paint);
      canvas.drawCircle(c + Offset(-s * 0.7, 10), s * 0.62, paint);
    }
    cloud(Offset(size.width * 0.2, size.height * yFactor), 42);
    cloud(Offset(size.width * 0.78, size.height * (yFactor + 0.08)), 36);
  }

  void _waves(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    for (var i = 0; i < 6; i++) {
      final y = size.height * (0.55 + i * 0.07);
      final path = Path()..moveTo(0, y);
      path.quadraticBezierTo(size.width * 0.25, y - 18, size.width * 0.5, y);
      path.quadraticBezierTo(size.width * 0.75, y + 18, size.width, y);
      canvas.drawPath(path, paint);
    }
  }

  void _stars(Canvas canvas, Size size, int count) {
    final rng = Random(42 + count);
    final paint = Paint()..color = Colors.white;
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height * 0.45),
        rng.nextDouble() * 1.8 + 0.6,
        paint,
      );
    }
  }

  void _tree(Canvas canvas, Offset base, double h) {
    canvas.drawRect(
      Rect.fromCenter(center: base, width: h * 0.12, height: h * 0.4),
      Paint()..color = const Color(0xFF5D4037),
    );
    canvas.drawCircle(
      base.translate(0, -h * 0.28),
      h * 0.28,
      Paint()..color = const Color(0xFF2E7D32),
    );
  }

  void _building(Canvas canvas, Rect rect, Random rng) {
    canvas.drawRect(rect, Paint()..color = Color.lerp(const Color(0xFF1B2438), const Color(0xFF3A2F66), rng.nextDouble())!);
    final win = Paint()..color = const Color(0xFFFFE082);
    for (var y = rect.top + 12; y < rect.bottom - 16; y += 18) {
      for (var x = rect.left + 8; x < rect.right - 10; x += 14) {
        if (rng.nextBool()) {
          canvas.drawRect(Rect.fromLTWH(x, y, 7, 10), win);
        }
      }
    }
  }

  void _rectBand(Canvas canvas, Size size, double start, double end, Color top, Color bottom) {
    final rect = Rect.fromLTRB(0, size.height * start, size.width, size.height * end);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [top, bottom]),
    );
  }
}
