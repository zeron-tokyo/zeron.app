import 'dart:math';
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
  final List<_Particle> _particles = <_Particle>[];
  final Random _random = Random();

  Size _lastSize = Size.zero;

  static const int _baseParticleCount = 110;
  static const int _maxAdditionalParticles = 70;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )
      ..addListener(_updateParticles)
      ..forward();

    _generateParticles();
  }

  void _generateParticles() {
    if (_particles.isNotEmpty) return;

    final int total =
        _baseParticleCount + (widget.ambientStage * 12);

    for (int i = 0; i < total; i++) {
      _particles.add(_Particle.random(_random));
    }
  }

  void _syncParticleCount() {
    final int targetCount = (_baseParticleCount +
        (widget.ambientStage * 12) +
        (widget.interactionEnergy * _maxAdditionalParticles).round())
        .clamp(_baseParticleCount, _baseParticleCount + _maxAdditionalParticles);

    if (_particles.length < targetCount) {
      final int addCount = targetCount - _particles.length;
      for (int i = 0; i < addCount; i++) {
        _particles.add(_Particle.random(_random));
      }
    } else if (_particles.length > targetCount) {
      _particles.removeRange(targetCount, _particles.length);
    }
  }

  void _updateParticles() {
    _syncParticleCount();

    final Offset normalizedPointer = _normalizedPointer();
    final double drift = sin(widget.presenceSeconds * 0.16) * 0.5 + 0.5;
    final double breath = sin(widget.presenceSeconds * 0.32) * 0.5 + 0.5;
    final double stageEnergy = (widget.ambientStage / 3.0).clamp(0.0, 1.0);

    for (final _Particle particle in _particles) {
      particle.update(
        pointer: normalizedPointer,
        drift: drift,
        breath: breath,
        interactionEnergy: widget.interactionEnergy,
        stageEnergy: stageEnergy,
        presenceSeconds: widget.presenceSeconds,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Offset _normalizedPointer() {
    if (_lastSize.width <= 0 || _lastSize.height <= 0) {
      return const Offset(0.5, 0.5);
    }

    return Offset(
      (widget.pointerPosition.dx / _lastSize.width).clamp(0.0, 1.0),
      (widget.pointerPosition.dy / _lastSize.height).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _lastSize = Size(constraints.maxWidth, constraints.maxHeight);

        return CustomPaint(
          painter: _BackgroundPainter(
            particles: _particles,
            presenceSeconds: widget.presenceSeconds,
            ambientStage: widget.ambientStage,
            interactionEnergy: widget.interactionEnergy,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.depth,
    required this.seed,
  });

  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  double depth;
  double seed;

  factory _Particle.random(Random random) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      vx: (random.nextDouble() - 0.5) * 0.0018,
      vy: (random.nextDouble() - 0.5) * 0.0018,
      size: 0.6 + (random.nextDouble() * 2.8),
      opacity: 0.08 + (random.nextDouble() * 0.32),
      depth: 0.4 + (random.nextDouble() * 0.9),
      seed: random.nextDouble() * pi * 2,
    );
  }

  void update({
    required Offset pointer,
    required double drift,
    required double breath,
    required double interactionEnergy,
    required double stageEnergy,
    required double presenceSeconds,
  }) {
    final double flowX = sin((y * 8.0) + (presenceSeconds * 0.12) + seed) *
        0.00022 *
        (0.7 + depth);
    final double flowY = cos((x * 7.0) - (presenceSeconds * 0.10) + seed) *
        0.00018 *
        (0.7 + depth);

    vx += flowX;
    vy += flowY;

    vx += (drift - 0.5) * 0.00012 * depth;
    vy += (breath - 0.5) * 0.00008 * depth;

    final double dx = x - pointer.dx;
    final double dy = y - pointer.dy;
    final double dist = sqrt((dx * dx) + (dy * dy));

    if (dist < 0.22) {
      final double force =
          (0.22 - dist) * (0.0009 + interactionEnergy * 0.0022);
      vx += dx * force * (1.2 + depth);
      vy += dy * force * (1.2 + depth);
    }

    final double speedLimit =
        0.0022 + (interactionEnergy * 0.0035) + (stageEnergy * 0.0015);
    vx = vx.clamp(-speedLimit, speedLimit);
    vy = vy.clamp(-speedLimit, speedLimit);

    x += vx;
    y += vy;

    vx *= 0.992;
    vy *= 0.992;

    if (x < -0.05) {
      x = 1.05;
    } else if (x > 1.05) {
      x = -0.05;
    }

    if (y < -0.05) {
      y = 1.05;
    } else if (y > 1.05) {
      y = -0.05;
    }
  }
}

class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter({
    required this.particles,
    required this.presenceSeconds,
    required this.ambientStage,
    required this.interactionEnergy,
  });

  final List<_Particle> particles;
  final double presenceSeconds;
  final int ambientStage;
  final double interactionEnergy;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    final double breath = sin(presenceSeconds * 0.28) * 0.5 + 0.5;
    final double stageBoost = (ambientStage * 0.05).clamp(0.0, 0.2);

    for (final _Particle particle in particles) {
      final double pulse = sin(
        (presenceSeconds * (0.6 + particle.depth * 0.3)) + particle.seed,
      ) *
          0.5 +
          0.5;

      final double opacity = (particle.opacity +
          (pulse * 0.10) +
          (breath * 0.06) +
          (interactionEnergy * 0.18) +
          stageBoost)
          .clamp(0.04, 0.72);

      final double radius = (particle.size +
          (pulse * 0.8) +
          (interactionEnergy * 0.9) +
          (ambientStage * 0.18))
          .clamp(0.4, 5.6);

      paint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.particles != particles ||
        oldDelegate.presenceSeconds != presenceSeconds ||
        oldDelegate.ambientStage != ambientStage ||
        oldDelegate.interactionEnergy != interactionEnergy;
  }
}