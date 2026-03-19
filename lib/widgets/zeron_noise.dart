import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ZeronNoise extends StatelessWidget {
  const ZeronNoise({
    super.key,
    required this.presenceSeconds,
    required this.ambientStage,
    required this.interactionEnergy,
    required this.isPointerInside,
  });

  final double presenceSeconds;
  final int ambientStage;
  final double interactionEnergy;
  final bool isPointerInside;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ZeronNoisePainter(
            presenceSeconds: presenceSeconds,
            ambientStage: ambientStage,
            interactionEnergy: interactionEnergy,
            isPointerInside: isPointerInside,
          ),
        ),
      ),
    );
  }
}

class _ZeronNoisePainter extends CustomPainter {
  _ZeronNoisePainter({
    required this.presenceSeconds,
    required this.ambientStage,
    required this.interactionEnergy,
    required this.isPointerInside,
  });

  final double presenceSeconds;
  final int ambientStage;
  final double interactionEnergy;
  final bool isPointerInside;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final double stage = ambientStage.clamp(0, 10).toDouble();
    final double t = presenceSeconds;

    final double energy = interactionEnergy;

    final double drift = math.sin(t * 0.08);
    final double pulse = (math.sin(t * 0.5) + 1.0) * 0.5;

    final double baseNoise = 0.0025 + stage * 0.0015;
    final double interactionBoost = energy * 0.008;
    final double pointerBoost = isPointerInside ? 0.002 : 0.0;

    _paintVignette(canvas, rect, baseNoise, interactionBoost);
    _paintAtmosphere(canvas, size, drift, pulse, baseNoise, interactionBoost, pointerBoost);
    _paintDepthLayers(canvas, size, drift, baseNoise);
    _paintGrain(canvas, size, baseNoise, interactionBoost, pointerBoost);
    _paintDust(canvas, size, pulse, baseNoise);
    _paintScan(canvas, size, pulse, baseNoise);
  }

  // ===== 外周暗部（存在感）=====
  void _paintVignette(Canvas canvas, Rect rect, double base, double boost) {
    final paint = Paint()
      ..shader = RadialGradient(
        radius: 1.15,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.04 + base * 8),
          Colors.black.withOpacity(0.12 + base * 18 + boost * 10),
        ],
        stops: const [0.0, 0.8, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  // ===== 空気（重要）=====
  void _paintAtmosphere(
    Canvas canvas,
    Size size,
    double drift,
    double pulse,
    double base,
    double boost,
    double pointer,
  ) {
    final double shortSide = math.min(size.width, size.height);

    final Offset c1 = Offset(
      size.width * (0.28 + drift * 0.02),
      size.height * 0.32,
    );

    final Offset c2 = Offset(
      size.width * (0.72 - drift * 0.02),
      size.height * 0.58,
    );

    final paintA = Paint()
      ..shader = ui.Gradient.radial(
        c1,
        shortSide * 0.6,
        [
          const Color(0xFF5A7CFF)
              .withOpacity(0.015 + base * 6 + pulse * 0.02),
          Colors.transparent,
        ],
      );

    final paintB = Paint()
      ..shader = ui.Gradient.radial(
        c2,
        shortSide * 0.7,
        [
          const Color(0xFF7FE6FF)
              .withOpacity(0.012 + base * 5 + pointer * 4),
          Colors.transparent,
        ],
      );

    canvas.drawCircle(c1, shortSide * 0.6, paintA);
    canvas.drawCircle(c2, shortSide * 0.7, paintB);
  }

  // ===== 奥行き =====
  void _paintDepthLayers(Canvas canvas, Size size, double drift, double base) {
    final List<double> xs = [0.18, 0.5, 0.82];

    for (int i = 0; i < xs.length; i++) {
      final double width = size.width * (0.06 + i * 0.02);

      final double x = size.width * xs[i] +
          math.sin(presenceSeconds * (0.05 + i * 0.02)) * 8;

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF9FD7FF).withOpacity(0.002 + base * 4),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(x, 0, width, size.height));

      canvas.drawRect(Rect.fromLTWH(x, 0, width, size.height), paint);
    }
  }

  // ===== 細かいノイズ =====
  void _paintGrain(
    Canvas canvas,
    Size size,
    double base,
    double boost,
    double pointer,
  ) {
    final int seed = (presenceSeconds * 80).floor() + ambientStage * 99;
    final random = math.Random(seed);

    final paint = Paint();

    final int count =
        70 + ambientStage * 10 + (interactionEnergy * 20).round();

    for (int i = 0; i < count; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;

      paint.color = Colors.white.withOpacity(
        (base + random.nextDouble() * 0.003 + boost + pointer)
            .clamp(0.0, 0.01),
      );

      canvas.drawRect(Rect.fromLTWH(x, y, 0.6, 0.6), paint);
    }
  }

  // ===== 微粒子 =====
  void _paintDust(
    Canvas canvas,
    Size size,
    double pulse,
    double base,
  ) {
    final random = math.Random(
        4000 + ambientStage * 33 + (presenceSeconds * 10).floor());

    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    for (int i = 0; i < 10 + ambientStage * 2; i++) {
      final Offset p = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );

      paint.color = const Color(0xFFBFE8FF).withOpacity(
        (base + pulse * 0.003).clamp(0.0, 0.01),
      );

      canvas.drawCircle(p, 1.2, paint);
    }
  }

  // ===== 走査線（微弱）=====
  void _paintScan(Canvas canvas, Size size, double pulse, double base) {
    final random =
        math.Random(8000 + (presenceSeconds * 6).floor());

    final int lines = 1 + ambientStage ~/ 4;

    for (int i = 0; i < lines; i++) {
      final double y = random.nextDouble() * size.height;

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFB8E7FF)
                .withOpacity((base + pulse * 0.002).clamp(0.0, 0.008)),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, y, size.width, 40));

      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 40), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZeronNoisePainter oldDelegate) {
    return oldDelegate.presenceSeconds != presenceSeconds ||
        oldDelegate.ambientStage != ambientStage ||
        oldDelegate.interactionEnergy != interactionEnergy ||
        oldDelegate.isPointerInside != isPointerInside;
  }
}