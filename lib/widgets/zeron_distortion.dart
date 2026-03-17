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
    final paint = Paint()..style = PaintingStyle.fill;

    final double pointerY =
        size.height == 0 ? 0.5 : (pointerPosition.dy / size.height).clamp(0.0, 1.0);

    // --- 横方向の“空間の歪み”（かなり弱く）
    final int bandCount = 3 + ambientStage;

    for (int i = 0; i < bandCount; i++) {
      final double progress = i / max(1, bandCount - 1);

      final double speed = 0.12 + (i * 0.05);

      final double height =
          22 + (ambientStage * 5) + (interactionEnergy * 16);

      final double centerY = size.height *
          (0.22 +
              progress * 0.56 +
              (sin((presenceSeconds * speed) + i) * 0.05) +
              ((pointerY - 0.5) * 0.08));

      final double dx =
          sin((presenceSeconds * (1.0 + i * 0.18)) + i) *
              (6 + ambientStage * 2.2) +
          (interactionEnergy * 14);

      final Rect rect = Rect.fromLTWH(
        dx,
        centerY,
        size.width,
        height,
      );

      paint.shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(
            alpha: (0.010 +
                    (ambientStage * 0.008) +
                    (interactionEnergy * 0.015))
                .clamp(0.0, 0.05),
          ),
          Colors.transparent,
        ],
      ).createShader(rect);

      canvas.drawRect(rect, paint);
    }

    // --- 微細なライン歪み（感じるレベル）
    if (ambientStage >= 1 || interactionEnergy > 0.04) {
      final int lineCount = 8 + ambientStage * 5;

      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < lineCount; i++) {
        final double y = size.height *
                ((i + 1) / (lineCount + 1)) +
            sin((presenceSeconds * 0.8) + i) *
                (1.8 + ambientStage.toDouble());

        final double shift =
            sin((presenceSeconds * 2.0) + i * 0.6) *
                (4 + ambientStage * 2.2 + interactionEnergy * 8);

        final double alpha = (0.012 +
                (ambientStage * 0.005) +
                (interactionEnergy * 0.012))
            .clamp(0.0, 0.05);

        linePaint
          ..strokeWidth = 0.6
          ..color = Colors.white.withValues(alpha: alpha);

        canvas.drawLine(
          Offset(-20 + shift, y),
          Offset(size.width + 20 + shift, y),
          linePaint,
        );
      }
    }

    // --- 空間の“膜”（ほぼ感じないレベル）
    if (ambientStage >= 2) {
      final Rect rect = Offset.zero & size;

      final paintVeil = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.006 + interactionEnergy * 0.008),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.008 + ambientStage * 0.005),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect);

      canvas.drawRect(rect, paintVeil);
    }
  }

  @override
  bool shouldRepaint(covariant _DistortionPainter old) {
    return true;
  }
}