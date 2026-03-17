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
    final rect = Offset.zero & size;

    final double flicker =
        ((sin(presenceSeconds * 12.0) + cos(presenceSeconds * 17.0)) * 0.5 + 1) /
            2;

    final double noiseOpacity = (0.018 +
        (ambientStage * 0.010) +
        (interactionEnergy * 0.040) +
        (isPointerInside ? 0.006 : 0.0))
        .clamp(0.0, 0.12);

    // --- 超薄スキャンライン（ほぼ見えない）
    final paintLine = Paint()..style = PaintingStyle.stroke;
    final double gap = max(2.5, 4.5 - (ambientStage * 0.3));

    for (double y = 0; y < size.height; y += gap) {
      final double alpha =
          noiseOpacity * (0.18 + (((y / gap) + flicker) % 3) * 0.05);

      paintLine
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: alpha);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintLine);
    }

    // --- 超微粒グレイン（主張を抑える）
    final random =
        Random((presenceSeconds * 900).floor() + ambientStage * 13);

    final paintGrain = Paint()..style = PaintingStyle.fill;

    final int grainCount =
        140 + (ambientStage * 50) + (interactionEnergy * 120).toInt();

    for (int i = 0; i < grainCount; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;

      final double s = 0.5 + random.nextDouble() * 1.6;

      final double density =
          0.9 + (sin((y / size.height) * pi) * 0.3);

      paintGrain.color = Colors.white.withValues(
        alpha: noiseOpacity *
            (0.08 + random.nextDouble() * 0.5) *
            density,
      );

      canvas.drawRect(Rect.fromLTWH(x, y, s, s), paintGrain);
    }

    // --- ビネット（空間締め）
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.06 + ambientStage * 0.025),
          Colors.black.withValues(alpha: 0.18 + ambientStage * 0.05),
        ],
        stops: const [0.0, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, vignette);

    // --- 横方向の“気配”（かなり弱く）
    final double hazeY =
        size.height * (0.32 + (sin(presenceSeconds * 0.4) * 0.06));

    final double haze =
        0.008 + (interactionEnergy * 0.015) + (ambientStage * 0.006);

    final hazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: haze),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          hazeY,
          size.width,
          100 + ambientStage * 18,
        ),
      );

    canvas.drawRect(rect, hazePaint);
  }

  @override
  bool shouldRepaint(covariant _ZeronNoisePainter old) {
    return true;
  }
}