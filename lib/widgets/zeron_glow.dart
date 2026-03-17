import 'dart:math';
import 'package:flutter/material.dart';

class ZeronGlow extends StatelessWidget {
  const ZeronGlow({
    super.key,
    required this.presenceSeconds,
    required this.ambientStage,
    required this.interactionEnergy,
    required this.pointerPosition,
    this.memoryPresence = 0.0,
    this.memoryType = 'none',
  });

  final double presenceSeconds;
  final int ambientStage;
  final double interactionEnergy;
  final Offset pointerPosition;
  final double memoryPresence;
  final String memoryType;

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
            memoryPresence: memoryPresence,
            memoryType: memoryType,
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
    required this.memoryPresence,
    required this.memoryType,
  });

  final double presenceSeconds;
  final int ambientStage;
  final double interactionEnergy;
  final Offset pointerPosition;
  final double memoryPresence;
  final String memoryType;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final double breath = (sin(presenceSeconds * 0.6) + 1) / 2;

    final double memoryBoost = memoryPresence.clamp(0.0, 0.14);

    final double px =
        size.width == 0 ? 0.5 : (pointerPosition.dx / size.width).clamp(0.0, 1.0);
    final double py =
        size.height == 0 ? 0.5 : (pointerPosition.dy / size.height).clamp(0.0, 1.0);

    final Alignment center = Alignment(
      ((px * 2) - 1) * 0.12,
      ((py * 2) - 1) * 0.08,
    );

    final double coreAlpha =
        0.04 + (breath * 0.02) + (ambientStage * 0.015) + (memoryBoost * 0.2);

    final double midAlpha =
        0.018 + (interactionEnergy * 0.025) + (memoryBoost * 0.1);

    final Paint main = Paint()
      ..shader = RadialGradient(
        center: center,
        radius: 0.55 +
            (ambientStage * 0.06) +
            (interactionEnergy * 0.12) +
            (memoryBoost * 0.25),
        colors: [
          Colors.white.withValues(alpha: coreAlpha),
          Colors.white.withValues(alpha: midAlpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, main);

    // 下部の空気感（かなり弱く）
    final Paint lower = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0,
          0.82 + (sin(presenceSeconds * 0.22) * 0.03),
        ),
        radius: 0.6 +
            (ambientStage * 0.07) +
            (interactionEnergy * 0.08) +
            (memoryBoost * 0.2),
        colors: [
          Colors.white.withValues(
            alpha: 0.02 +
                (ambientStage * 0.015) +
                (interactionEnergy * 0.02) +
                (memoryBoost * 0.12),
          ),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, lower);

    // エッジ密度（ほぼ感じないレベル）
    if (ambientStage >= 2 || interactionEnergy > 0.15 || memoryPresence > 0.02) {
      final Paint edge = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(
              alpha: 0.008 +
                  (interactionEnergy * 0.01) +
                  (memoryBoost * 0.05),
            ),
            Colors.transparent,
            Colors.white.withValues(
              alpha: 0.01 +
                  (ambientStage * 0.006) +
                  (memoryBoost * 0.06),
            ),
          ],
        ).createShader(rect);

      canvas.drawRect(rect, edge);
    }

    // memory: active（ほぼ見えない脈動）
    if (memoryType == 'active') {
      final Paint pulse = Paint()
        ..shader = RadialGradient(
          center: center,
          radius: 0.28 +
              (sin(presenceSeconds * 1.4) * 0.015) +
              (memoryBoost * 0.2),
          colors: [
            Colors.white.withValues(alpha: 0.01 + memoryBoost * 0.12),
            Colors.transparent,
          ],
        ).createShader(rect);

      canvas.drawRect(rect, pulse);
    }

    // memory: still（静かな膜）
    if (memoryType == 'still') {
      final Paint veil = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.006 + memoryBoost * 0.05),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.008 + memoryBoost * 0.06),
          ],
        ).createShader(rect);

      canvas.drawRect(rect, veil);
    }
  }

  @override
  bool shouldRepaint(covariant _ZeronGlowPainter old) {
    return true;
  }
}