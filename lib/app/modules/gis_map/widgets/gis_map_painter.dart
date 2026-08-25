import 'package:flutter/material.dart';

class GisMapPainter extends CustomPainter {
  final bool showHeatmap;

  GisMapPainter({required this.showHeatmap});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background Terrain Gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D1A0F), Color(0xFF0A1208), Color(0xFF0F1510)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // 2. Terrain Patches
    final patchPaint1 = Paint()..color = const Color(0x33283C1E);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.4, h * 0.38), width: w * 0.65, height: h * 0.3),
      patchPaint1,
    );

    final patchPaint2 = Paint()..color = const Color(0x281E3219);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.68, h * 0.52), width: w * 0.5, height: h * 0.25),
      patchPaint2,
    );

    // 3. Contour Elevation Lines
    final contourPaint = Paint()
      ..color = const Color(0x1800C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 5; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.42),
          width: w * (0.3 + i * 0.12),
          height: h * (0.16 + i * 0.07),
        ),
        contourPaint,
      );
    }

    // 4. River Path
    final riverBg = Paint()
      ..color = const Color(0x350064B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    final riverFg = Paint()
      ..color = const Color(0x250096DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(w * 0.15, h * 0.18);
    riverPath.quadraticBezierTo(w * 0.35, h * 0.32, w * 0.42, h * 0.42);
    riverPath.quadraticBezierTo(w * 0.50, h * 0.52, w * 0.60, h * 0.68);
    riverPath.quadraticBezierTo(w * 0.68, h * 0.76, w * 0.82, h * 0.88);

    canvas.drawPath(riverPath, riverBg);
    canvas.drawPath(riverPath, riverFg);

    // 5. Claim Zone A-7 Boundary (Dashed Polygon)
    final claimPaint = Paint()
      ..color = const Color(0x50D4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final claimFillPaint = Paint()..color = const Color(0x0AD4AF37);

    final claimPath = Path();
    claimPath.moveTo(w * 0.28, h * 0.24);
    claimPath.lineTo(w * 0.72, h * 0.22);
    claimPath.lineTo(w * 0.80, h * 0.50);
    claimPath.lineTo(w * 0.70, h * 0.64);
    claimPath.lineTo(w * 0.34, h * 0.62);
    claimPath.lineTo(w * 0.22, h * 0.40);
    claimPath.close();

    canvas.drawPath(claimPath, claimFillPaint);
    canvas.drawPath(claimPath, claimPaint);

    // 6. Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0x0C00E5FF)
      ..strokeWidth = 0.5;

    for (double x = 0; x < w; x += w / 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += h / 8) {
      canvas.drawLine(Offset(y, y), Offset(w, y), gridPaint);
    }

    // 7. Heatmap glow
    if (showHeatmap) {
      final heatPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.18),
            const Color(0xFF00C853).withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(w * 0.5, h * 0.38), radius: w * 0.35),
        );
      canvas.drawCircle(Offset(w * 0.5, h * 0.38), w * 0.35, heatPaint);
    }

    // 8. Compass in top right
    _drawCompass(canvas, Offset(w - 36, 40));

    // 9. Scale bar in bottom left
    _drawScaleBar(canvas, Offset(24, h - 30));
  }

  void _drawCompass(Canvas canvas, Offset center) {
    final bg = Paint()..color = const Color(0xCC0F1217);
    final border = Paint()
      ..color = const Color(0x40D4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 16, bg);
    canvas.drawCircle(center, 16, border);

    // North arrow
    final northPaint = Paint()..color = const Color(0xFFD4AF37);
    final northPath = Path()
      ..moveTo(center.dx, center.dy - 11)
      ..lineTo(center.dx - 3, center.dy)
      ..lineTo(center.dx + 3, center.dy)
      ..close();
    canvas.drawPath(northPath, northPaint);

    // South arrow
    final southPaint = Paint()..color = const Color(0xFF4B5563);
    final southPath = Path()
      ..moveTo(center.dx, center.dy + 11)
      ..lineTo(center.dx - 3, center.dy)
      ..lineTo(center.dx + 3, center.dy)
      ..close();
    canvas.drawPath(southPath, southPaint);
  }

  void _drawScaleBar(Canvas canvas, Offset start) {
    final barPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;

    canvas.drawLine(start, Offset(start.dx + 50, start.dy), barPaint);
    canvas.drawLine(start, Offset(start.dx, start.dy - 4), barPaint);
    canvas.drawLine(Offset(start.dx + 50, start.dy), Offset(start.dx + 50, start.dy - 4), barPaint);
  }

  @override
  bool shouldRepaint(covariant GisMapPainter oldDelegate) =>
      oldDelegate.showHeatmap != showHeatmap;
}
