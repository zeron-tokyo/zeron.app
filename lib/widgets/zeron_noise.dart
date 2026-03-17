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

    final double stageBoost = ambientStage * 0.004;
    final double interactionBoost = interactionEnergy * 0.012;
    final double pointerBoost = isPointerInside ? 0.004 : 0.0;
    final double shimmer = ((sin(presenceSeconds * 0.7) + 1) * 0.5) * 0.004;

    final Paint vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.08,
        colors: <Color>[
          Colors.transparent,
          Colors.black.withValues(alpha: 0.06 + stageBoost),
          Colors.black.withValues(
            alpha: 0.18 + stageBoost + interactionBoost * 0.5,
          ),
        ],
        stops: const <double>[0.0, 0.74, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, vignettePaint);

    final double hazeHeight = 84 + (ambientStage * 10);
    final double hazeY =
        size.height * (0.35 + sin(presenceSeconds * 0.22) * 0.03);

    final Paint hazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.transparent,
          Colors.white.withValues(
            alpha: 0.007 + shimmer + pointerBoost * 0.4,
          ),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(0, hazeY, size.width, hazeHeight),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, hazeY, size.width, hazeHeight),
      hazePaint,
    );

    final Random random =
        Random((presenceSeconds * 60).floor() + ambientStage * 97);

    final Paint grainPaint = Paint()..style = PaintingStyle.fill;
    final int grainCount = 34 +
        (ambientStage * 8) +
        (interactionEnergy * 18).round() +
        (isPointerInside ? 6 : 0);

    for (int i = 0; i < grainCount; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double s = 0.55 + random.nextDouble() * 0.75;

      grainPaint.color = Colors.white.withValues(
        alpha: (0.012 +
                random.nextDouble() * 0.018 +
                stageBoost * 0.4 +
                interactionBoost * 0.35)
            .clamp(0.0, 0.03),
      );

      canvas.drawRect(Rect.fromLTWH(x, y, s, s), grainPaint);
    }

    final double lineAlpha =
        (0.006 + stageBoost * 0.4 + pointerBoost * 0.4).clamp(0.0, 0.012);

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: lineAlpha);

    final double gap = 22 + ambientStage * 2.0;
    for (double y = 10; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZeronNoisePainter oldDelegate) => true;
}