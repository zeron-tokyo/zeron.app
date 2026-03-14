import 'dart:math';

import 'package:flutter/material.dart';

class ZeronBackground extends StatelessWidget {
  const ZeronBackground({
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
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ZeronBackgroundPainter(
          presenceSeconds: presenceSeconds,
          ambientStage: ambientStage,
          interactionEnergy: interactionEnergy,
          pointerPosition: pointerPosition,
        ),
      ),
    );
  }
}

class _ParticleSeed {
  const _ParticleSeed({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.depth,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
  final double depth;
}

class _ZeronBackgroundPainter extends CustomPainter {
  _ZeronBackgroundPainter({
    required this.presenceSeconds,
    required this.ambientStage,
    required this.interactionEnergy,
    required this.pointerPosition,
  });

  final double presenceSeconds;
  final int ambientStage;
  final double interactionEnergy;
  final Offset pointerPosition;

  static final List<_ParticleSeed> _particles = List<_ParticleSeed>.generate(
    96,
        (int index) {
      final Random random = Random(index * 9173);
      return _ParticleSeed(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 0.7 + (random.nextDouble() * 2.6),
        speed: 0.15 + (random.nextDouble() * 0.8),
        phase: random.nextDouble() * pi * 2,
        depth: 0.35 + (random.nextDouble() * 0.65),
      );
    },
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.012 + ambientStage * 0.005),
          Colors.transparent,
          Colors.white.withValues(alpha: 0.02 + interactionEnergy * 0.03),
        ],
        stops: const <double>[0.0, 0.56, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, basePaint);

    final Paint particlePaint = Paint()..style = PaintingStyle.fill;
    final Paint trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Offset pointerNormalized = Offset(
      size.width == 0 ? 0.5 : (pointerPosition.dx / size.width).clamp(0.0, 1.0),
      size.height == 0 ? 0.5 : (pointerPosition.dy / size.height).clamp(0.0, 1.0),
    );

    final double stageDrift = 4 + (ambientStage * 5.0);
    final double energyDrift = interactionEnergy * 16.0;
    final double presenceWave = sin(presenceSeconds * 0.18);

    for (final _ParticleSeed particle in _particles) {
      final double t = (presenceSeconds * particle.speed) + particle.phase;

      final double baseX = particle.x * size.width;
      final double baseY = particle.y * size.height;

      final double driftX = sin(t * 0.9) * (stageDrift + (particle.depth * 8));
      final double driftY = cos(t * 0.75) * (6 + (particle.depth * 12));

      final double pointerPullX =
          (pointerNormalized.dx - particle.x) * energyDrift * particle.depth * 8;
      final double pointerPullY =
          (pointerNormalized.dy - particle.y) * energyDrift * particle.depth * 8;

      final double x = baseX + driftX + pointerPullX;
      final double y = baseY + driftY + pointerPullY;

      final double radius = particle.radius +
          (ambientStage * 0.16) +
          (interactionEnergy * 0.9 * particle.depth) +
          (presenceWave * 0.08);

      final double alpha = (0.09 +
          (particle.depth * 0.13) +
          (ambientStage * 0.02) +
          (interactionEnergy * 0.08))
          .clamp(0.0, 0.34);

      particlePaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, particlePaint);

      if (ambientStage >= 1 || interactionEnergy > 0.08) {
        final double trailLength =
            8 + (ambientStage * 4.0) + (interactionEnergy * 18.0);
        final Offset end = Offset(
          x - (sin(t) * trailLength),
          y - (cos(t * 0.85) * trailLength),
        );

        trailPaint
          ..strokeWidth = 0.6 + (particle.depth * 0.8)
          ..color = Colors.white.withValues(alpha: alpha * 0.28);

        canvas.drawLine(Offset(x, y), end, trailPaint);
      }
    }

    final Paint veilPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          ((pointerNormalized.dx * 2) - 1) * 0.35,
          ((pointerNormalized.dy * 2) - 1) * 0.35,
        ),
        radius: 1.1 + (ambientStage * 0.08),
        colors: <Color>[
          Colors.white.withValues(alpha: 0.02 + interactionEnergy * 0.04),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.12 + ambientStage * 0.035),
        ],
        stops: const <double>[0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, veilPaint);
  }

  @override
  bool shouldRepaint(covariant _ZeronBackgroundPainter oldDelegate) {
    return oldDelegate.presenceSeconds != presenceSeconds ||
        oldDelegate.ambientStage != ambientStage ||
        oldDelegate.interactionEnergy != interactionEnergy ||
        oldDelegate.pointerPosition != pointerPosition;
  }
}