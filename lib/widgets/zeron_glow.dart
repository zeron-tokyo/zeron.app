import 'dart:math';

import 'package:flutter/material.dart';

class ZeronGlow extends StatelessWidget {
  const ZeronGlow({
    super.key,
    required this.presenceSeconds,
    required this.ambientStage,
    required this.interactionEnergy,
    required this.pointerPosition,
  });

  final double presenceSeconds;
  final int ambientStage;
  final double interactionEnergy;
  final Offset pointerPosition;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ZeronGlowPainter(
            presenceSeconds: presenceSeconds,
            ambientStage: ambientStage,
            interactionEnergy: interactionEnergy,
            pointerPosition: pointerPosition,
          ),
        ),
      ),
    );
  }
}

class _ZeronGlowPainter extends CustomPainter {
  _ZeronGlowPainter({
    required this.presenceSeconds,
    required this.ambientStage,
    required this.interactionEnergy,
    required this.pointerPosition,
  });

  final double presenceSeconds;
  final int ambientStage;
  final double interactionEnergy;
  final Offset pointerPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final double breath = (sin(presenceSeconds * 0.9) + 1) / 2;
    final double stageSpread = 0.52 + (ambientStage * 0.07);
    final double energyBoost = interactionEnergy * 0.24;

    final double px = size.width == 0 ? 0.5 : (pointerPosition.dx / size.width);
    final double py = size.height == 0 ? 0.5 : (pointerPosition.dy / size.height);

    final Alignment centerA = Alignment(
      ((px * 2) - 1) * 0.12,
      ((py * 2) - 1) * 0.08,
    );

    final Paint mainGlow = Paint()
      ..shader = RadialGradient(
        center: centerA,
        radius: stageSpread + energyBoost,
        colors: <Color>[
          Colors.white.withValues(
            alpha: 0.065 + (breath * 0.03) + (ambientStage * 0.015),
          ),
          Colors.white.withValues(
            alpha: 0.028 + (interactionEnergy * 0.04),
          ),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.36, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, mainGlow);

    final Paint lowerBloom = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0,
          0.78 + (sin(presenceSeconds * 0.3) * 0.03),
        ),
        radius: 0.72 + (ambientStage * 0.08) + (interactionEnergy * 0.1),
        colors: <Color>[
          Colors.white.withValues(
            alpha: 0.03 + (ambientStage * 0.02) + (interactionEnergy * 0.04),
          ),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, lowerBloom);

    if (ambientStage >= 2 || interactionEnergy > 0.18) {
      final Paint edgeGlow = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.012 + (interactionEnergy * 0.02)),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.018 + (ambientStage * 0.008)),
          ],
        ).createShader(rect);

      canvas.drawRect(rect, edgeGlow);
    }
  }

  @override
  bool shouldRepaint(covariant _ZeronGlowPainter oldDelegate) {
    return oldDelegate.presenceSeconds != presenceSeconds ||
        oldDelegate.ambientStage != ambientStage ||
        oldDelegate.interactionEnergy != interactionEnergy ||
        oldDelegate.pointerPosition != pointerPosition;
  }
}