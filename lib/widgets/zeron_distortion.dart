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

      final double travelSpeed = 0.18 + (i * 0.08);

      final double bandHeight =
          26 + (ambientStage * 6) + (interactionEnergy * 22);

      final double centerY = size.height *
          (0.18 +
              progress * 0.64 +
              (sin((presenceSeconds * travelSpeed) + i) * 0.065) +
              ((pointerY - 0.5) * 0.11));

      final double dx = sin((presenceSeconds * (1.4 + i * 0.22)) + i) *
          (9 + ambientStage * 3.5) +
          (interactionEnergy * 26);

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
            alpha: (0.016 +
                (ambientStage * 0.011) +
                (interactionEnergy * 0.022))
                .clamp(0.0, 0.09),
          ),
          Colors.transparent,
        ],
      ).createShader(bandRect);

      canvas.drawRect(bandRect, paint);
    }

    if (ambientStage >= 1 || interactionEnergy > 0.05) {
      final int lineCount = 12 + ambientStage * 7;

      final Paint linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < lineCount; i++) {
        final double y = size.height *
            ((i + 1) / (lineCount + 1)) +
            sin((presenceSeconds * 1.0) + i) *
                (2.4 + ambientStage.toDouble());

        final double shift = sin((presenceSeconds * 2.6) + i * 0.75) *
            (7 + ambientStage * 3.5 + interactionEnergy * 14);

        final double alpha = (0.02 +
            (ambientStage * 0.007) +
            (interactionEnergy * 0.02) +
            (i.isEven ? 0.005 : 0.0))
            .clamp(0.0, 0.08);

        linePaint
          ..strokeWidth = 0.7 + (i % 3) * 0.25
          ..color = Colors.white.withValues(alpha: alpha);

        canvas.drawLine(
          Offset(-20 + shift, y),
          Offset(size.width + 20 + shift, y),
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
            Colors.white.withValues(
                alpha: 0.01 + interactionEnergy * 0.012),
            Colors.transparent,
            Colors.white.withValues(
                alpha: 0.014 + ambientStage * 0.007),
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