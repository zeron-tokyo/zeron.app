import 'dart:math';

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
          size: Size.infinite,
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

    final double flicker =
        ((sin(presenceSeconds * 13.0) + cos(presenceSeconds * 17.0)) * 0.5 + 1) /
            2;

    final double noiseOpacity = (0.03 +
        (ambientStage * 0.012) +
        (interactionEnergy * 0.05) +
        (isPointerInside ? 0.01 : 0.0))
        .clamp(0.0, 0.16);

    final Paint scanlinePaint = Paint()..style = PaintingStyle.stroke;

    final double lineGap = max(2.0, 4.0 - (ambientStage * 0.35));
    for (double y = 0; y < size.height; y += lineGap) {
      final double alpha = noiseOpacity *
          (0.35 + (((y / lineGap) + flicker) % 3) * 0.08);

      scanlinePaint
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: alpha);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanlinePaint);
    }

    final Random random = Random((presenceSeconds * 1000).floor() + ambientStage);

    final Paint grainPaint = Paint()..style = PaintingStyle.fill;
    final int grainCount = 180 + (ambientStage * 70) + (interactionEnergy * 140).toInt();

    for (int i = 0; i < grainCount; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double w = 0.8 + random.nextDouble() * 1.8;
      final double h = 0.8 + random.nextDouble() * 1.8;

      grainPaint.color = Colors.white.withValues(
        alpha: noiseOpacity * (0.12 + random.nextDouble() * 0.65),
      );

      canvas.drawRect(Rect.fromLTWH(x, y, w, h), grainPaint);
    }

    final Paint vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.08,
        colors: <Color>[
          Colors.transparent,
          Colors.black.withValues(alpha: 0.08 + ambientStage * 0.03),
          Colors.black.withValues(alpha: 0.2 + ambientStage * 0.06),
        ],
        stops: const <double>[0.0, 0.72, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, vignette);

    final Paint horizontalHaze = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          Colors.transparent,
          Colors.white.withValues(alpha: 0.01 + interactionEnergy * 0.015),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          size.height * (0.32 + (sin(presenceSeconds * 0.6) * 0.08)),
          size.width,
          120,
        ),
      );

    canvas.drawRect(rect, horizontalHaze);
  }

  @override
  bool shouldRepaint(covariant _ZeronNoisePainter oldDelegate) {
    return oldDelegate.presenceSeconds != presenceSeconds ||
        oldDelegate.ambientStage != ambientStage ||
        oldDelegate.interactionEnergy != interactionEnergy ||
        oldDelegate.isPointerInside != isPointerInside;
  }
}