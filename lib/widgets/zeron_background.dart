import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ZeronBackground extends StatefulWidget {
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
  State<ZeronBackground> createState() => _ZeronBackgroundState();
}

class _ZeronBackgroundState extends State<ZeronBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_StarParticle> _particles;

  static const int _particleCount = 260; // 少し削減して安定化

  @override
  void initState() {
    super.initState();

    final random = math.Random(77);
    _particles = List.generate(
      _particleCount,
      (_) => _StarParticle.random(random),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary( // ★重要：パフォーマンス最適化
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final blendedTime =
                (_controller.value + widget.presenceSeconds * 0.018) % 1.0;

            return CustomPaint(
              painter: _ZeronBackgroundPainter(
                particles: _particles,
                time: blendedTime,
                presenceSeconds: widget.presenceSeconds,
                ambientStage: widget.ambientStage,
                interactionEnergy: widget.interactionEnergy,
                pointer: widget.pointerPosition,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ZeronBackgroundPainter extends CustomPainter {
  _ZeronBackgroundPainter({
    required this.particles,
    required this.time,
    required this.presenceSeconds,
    required this.ambientStage,
    required this.interactionEnergy,
    required this.pointer,
  });

  final List<_StarParticle> particles;
  final double time;
  final double presenceSeconds;
  final int ambientStage;
  final double interactionEnergy;
  final Offset pointer;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    _paintBaseSpace(canvas, rect);
    _paintNebula(canvas, size);

    final center = Offset(size.width / 2, size.height / 2);
    final orbitBase = math.max(size.width, size.height) * 0.56;
    final flowT = time * math.pi * 2.0;
    final pointerActive = pointer != Offset.zero;

    for (final p in particles) {
      final travel = (p.seed + time * p.forwardSpeed) % 1.0;
      final eased = Curves.easeOutCubic.transform(travel);

      final orbitRadius =
          ui.lerpDouble(orbitBase * 0.05, orbitBase * 1.2, eased)!;

      final angle =
          p.baseAngle + flowT * p.rotationSpeed + orbitRadius * p.spiralTightness;

      double x = center.dx + math.cos(angle) * orbitRadius;
      double y = center.dy + math.sin(angle) * orbitRadius * p.verticalFlatten;

      Offset point = Offset(x, y);

      // ===== カーソル反応（大幅改善）=====
      if (pointerActive) {
        final toPoint = point - pointer;
        final distance = toPoint.distance;

        final radius = 220 + ambientStage * 30;

        if (distance < radius) {
          final power = 1.0 - (distance / radius);
          final force = Curves.easeOut.transform(power);

          final dir = distance < 0.001
              ? Offset(math.cos(p.baseAngle), math.sin(p.baseAngle))
              : toPoint / distance;

          // 放射 + 渦
          final radial = dir * (force * 120 * (1 + interactionEnergy * 0.5));
          final swirl = Offset(-dir.dy, dir.dx) *
              (force * 40 * (p.swirlDirection));

          point += radial + swirl;
        }
      }

      final sizePx = ui.lerpDouble(0.5, p.maxSize + ambientStage * 0.2, eased)!;
      final alpha = (0.15 + eased * 0.85) * p.alpha;

      final color = Color.lerp(
        const Color(0xFF78D6FF),
        Colors.white,
        p.colorMix,
      )!
          .withOpacity(alpha);

      final paint = Paint()..color = color;

      canvas.drawCircle(point, sizePx, paint);
    }

    _paintCenterAura(canvas, size, center);
  }

  void _paintBaseSpace(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF02040A),
          Color(0xFF040915),
          Color(0xFF010204),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintNebula(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.2),
        radius: 0.8,
        colors: [
          const Color(0xFF4966FF).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintCenterAura(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..shader = RadialGradient(
        radius: 0.25,
        colors: [
          const Color(0xFF8DD7FF).withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: math.min(size.width, size.height) * 0.25,
        ),
      );

    canvas.drawCircle(
      center,
      math.min(size.width, size.height) * 0.25,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ZeronBackgroundPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.pointer != pointer ||
        oldDelegate.interactionEnergy != interactionEnergy ||
        oldDelegate.ambientStage != ambientStage;
  }
}

class _StarParticle {
  _StarParticle({
    required this.seed,
    required this.baseAngle,
    required this.forwardSpeed,
    required this.rotationSpeed,
    required this.spiralTightness,
    required this.verticalFlatten,
    required this.maxSize,
    required this.alpha,
    required this.colorMix,
    required this.swirlDirection,
  });

  final double seed;
  final double baseAngle;
  final double forwardSpeed;
  final double rotationSpeed;
  final double spiralTightness;
  final double verticalFlatten;
  final double maxSize;
  final double alpha;
  final double colorMix;
  final double swirlDirection;

  factory _StarParticle.random(math.Random random) {
    return _StarParticle(
      seed: random.nextDouble(),
      baseAngle: random.nextDouble() * math.pi * 2,
      forwardSpeed: 0.2 + random.nextDouble() * 0.4,
      rotationSpeed: 0.1 + random.nextDouble() * 0.3,
      spiralTightness: 0.002 + random.nextDouble() * 0.003,
      verticalFlatten: 0.5 + random.nextDouble() * 0.3,
      maxSize: 1.0 + random.nextDouble() * 2.5,
      alpha: 0.3 + random.nextDouble() * 0.6,
      colorMix: random.nextDouble(),
      swirlDirection: random.nextBool() ? 1.0 : -1.0,
    );
  }
}