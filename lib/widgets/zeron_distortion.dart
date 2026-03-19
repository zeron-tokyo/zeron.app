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
    final Paint paint = Paint();

    final bool pointerActive = pointerPosition != Offset.zero;

    final double pointerX = pointerActive
        ? (pointerPosition.dx / size.width).clamp(0.0, 1.0)
        : 0.5;

    final double pointerY = pointerActive
        ? (pointerPosition.dy / size.height).clamp(0.0, 1.0)
        : 0.5;

    final Offset pointer = Offset(pointerX * size.width, pointerY * size.height);

    final int fieldCount = 2 + ambientStage;

    // =========================
    // 空間歪みフィールド（本体）
    // =========================
    for (int i = 0; i < fieldCount; i++) {
      final double t = presenceSeconds * (0.25 + i * 0.08);

      final double baseY =
          size.height * (0.3 + (i / fieldCount) * 0.4);

      final double amplitude =
          10 + ambientStage * 4 + interactionEnergy * 14;

      final double thickness =
          80 + ambientStage * 14 + interactionEnergy * 30;

      final Path path = Path();

      for (double x = -60; x <= size.width + 60; x += 6) {
        double y = baseY +
            sin((x * 0.012) + t) * amplitude;

        // ===== 重力歪み =====
        if (pointerActive) {
          final dx = x - pointer.dx;
          final dy = y - pointer.dy;

          final dist = sqrt(dx * dx + dy * dy);

          final influence = (1 - (dist / 260)).clamp(0.0, 1.0);

          if (influence > 0) {
            final warp = pow(influence, 2) *
                (40 + interactionEnergy * 60);

            y += (dy / (dist + 0.001)) * warp;
          }
        }

        if (x == -60) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      for (double x = size.width + 60; x >= -60; x -= 6) {
        double y = baseY +
            sin((x * 0.012) + t) * amplitude +
            thickness;

        if (pointerActive) {
          final dx = x - pointer.dx;
          final dy = y - pointer.dy;

          final dist = sqrt(dx * dx + dy * dy);

          final influence = (1 - (dist / 260)).clamp(0.0, 1.0);

          if (influence > 0) {
            final warp = pow(influence, 2) *
                (40 + interactionEnergy * 60);

            y += (dy / (dist + 0.001)) * warp;
          }
        }

        path.lineTo(x, y);
      }

      path.close();

      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(
            (0.004 +
                    ambientStage * 0.004 +
                    interactionEnergy * 0.008)
                .clamp(0.0, 0.025),
          ),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          baseY - thickness,
          size.width,
          thickness * 2,
        ),
      );

      canvas.drawPath(path, paint);
    }

    // =========================
    // 微細ゆらぎ（空間ノイズ）
    // =========================
    if (ambientStage >= 1 || interactionEnergy > 0.05) {
      final int rippleCount = 3 + ambientStage;

      for (int i = 0; i < rippleCount; i++) {
        final double t = presenceSeconds * (0.8 + i * 0.2);

        final double centerY =
            size.height * (0.2 + (i / rippleCount) * 0.6);

        final Path path = Path();

        for (double x = 0; x <= size.width; x += 8) {
          double y = centerY +
              sin((x * 0.02) + t) *
                  (4 + ambientStage * 2 + interactionEnergy * 8);

          if (pointerActive) {
            final dx = x - pointer.dx;
            final dy = y - pointer.dy;
            final dist = sqrt(dx * dx + dy * dy);

            final influence = (1 - (dist / 220)).clamp(0.0, 1.0);

            if (influence > 0) {
              y += dy * influence * 0.15;
            }
          }

          if (x == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }

        final ripplePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withOpacity(
            (0.002 +
                    ambientStage * 0.002 +
                    interactionEnergy * 0.005)
                .clamp(0.0, 0.015),
          );

        canvas.drawPath(path, ripplePaint);
      }
    }

    // =========================
    // 空間ヴェール（深度）
    // =========================
    if (ambientStage >= 2) {
      final Rect rect = Offset.zero & size;

      final paintVeil = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(
                0.003 + interactionEnergy * 0.005),
            Colors.transparent,
            Colors.white.withOpacity(
                0.004 + ambientStage * 0.004),
          ],
        ).createShader(rect);

      canvas.drawRect(rect, paintVeil);
    }
  }

  @override
  bool shouldRepaint(covariant _DistortionPainter old) {
    return old.presenceSeconds != presenceSeconds ||
        old.ambientStage != ambientStage ||
        old.interactionEnergy != interactionEnergy ||
        old.pointerPosition != pointerPosition;
  }
}