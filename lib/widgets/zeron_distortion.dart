import 'dart:math';

import 'package:flutter/material.dart';

class ZeronDistortion extends StatelessWidget {
  const ZeronDistortion({
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
          painter: _DistortionPainter(
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

class _DistortionPainter extends CustomPainter {
  _DistortionPainter({
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
    final Paint paint = Paint()..style = PaintingStyle.fill;

    final double pointerY =
    size.height == 0 ? 0.5 : (pointerPosition.dy / size.height).clamp(0.0, 1.0);

    final int bandCount = 4 + ambientStage;
    for (int i = 0; i < bandCount; i++) {
      final double progress = i / max(1, bandCount - 1);
      final double travelSpeed = 0.18 + (i * 0.07);
      final double bandHeight = 24 + (ambientStage * 5) + (interactionEnergy * 18);

      final double centerY = size.height *
          (0.18 +
              progress * 0.64 +
              (sin((presenceSeconds * travelSpeed) + i) * 0.05) +
              ((pointerY - 0.5) * 0.08));

      final double dx = sin((presenceSeconds * (1.3 + i * 0.2)) + i) *
          (8 + ambientStage * 3) +
          (interactionEnergy * 22);

      final Rect bandRect = Rect.fromLTWH(
        dx,
        centerY,
        size.width,
        bandHeight,
      );

      paint.shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          Colors.transparent,
          Colors.white.withValues(
            alpha: (0.014 + (ambientStage * 0.01) + (interactionEnergy * 0.02))
                .clamp(0.0, 0.08),
          ),
          Colors.transparent,
        ],
      ).createShader(bandRect);

      canvas.drawRect(bandRect, paint);
    }

    if (ambientStage >= 1 || interactionEnergy > 0.05) {
      final int lineCount = 10 + ambientStage * 6;
      final Paint linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < lineCount; i++) {
        final double y = size.height *
            ((i + 1) / (lineCount + 1)) +
            sin((presenceSeconds * 0.9) + i) * (2 + ambientStage.toDouble());

        final double shift = sin((presenceSeconds * 2.4) + i * 0.7) *
            (6 + ambientStage * 3 + interactionEnergy * 12);

        final double alpha = (0.018 +
            (ambientStage * 0.006) +
            (interactionEnergy * 0.018) +
            (i.isEven ? 0.004 : 0.0))
            .clamp(0.0, 0.07);

        linePaint
          ..strokeWidth = 0.7 + (i % 3) * 0.2
          ..color = Colors.white.withValues(alpha: alpha);

        canvas.drawLine(
          Offset(-18 + shift, y),
          Offset(size.width + 18 + shift, y),
          linePaint,
        );
      }
    }

    if (ambientStage >= 2) {
      final Rect veilRect = Offset.zero & size;
      final Paint veilPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.008 + interactionEnergy * 0.01),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.012 + ambientStage * 0.006),
          ],
          stops: const <double>[0.0, 0.5, 1.0],
        ).createShader(veilRect);

      canvas.drawRect(veilRect, veilPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DistortionPainter oldDelegate) {
    return oldDelegate.presenceSeconds != presenceSeconds ||
        oldDelegate.ambientStage != ambientStage ||
        oldDelegate.interactionEnergy != interactionEnergy ||
        oldDelegate.pointerPosition != pointerPosition;
  }
}