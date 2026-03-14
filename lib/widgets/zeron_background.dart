import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ZeronBackground extends StatefulWidget {
  const ZeronBackground({
    super.key,
    this.pointerPosition,
  });

  final Offset? pointerPosition;

  @override
  State<ZeronBackground> createState() => _ZeronBackgroundState();
}

class _ZeronBackgroundState extends State<ZeronBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final Random _random = Random();

  double _globalPhase = 0.0;

  @override
  void initState() {
    super.initState();

    _particles = List.generate(70, (_) => _createParticle());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )
      ..addListener(_tick)
      ..repeat();
  }

  _Particle _createParticle() {
    final depth = _random.nextDouble();

    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      radius: lerpDouble(0.8, 2.2, depth)!,
      opacity: lerpDouble(0.18, 0.55, depth)!,
      speed: lerpDouble(0.00008, 0.00045, depth)!,
      drift: lerpDouble(0.00002, 0.00010, depth)!,
      seed: _random.nextDouble() * pi * 2,
    );
  }

  void _tick() {
    final pointer = widget.pointerPosition;
    final screenSize = MediaQuery.of(context).size;

    _globalPhase += 0.0035;

    for (final particle in _particles) {
      particle.y += particle.speed;

      final localWave = sin((particle.y * 12) + particle.seed + _globalPhase);
      final globalWave = sin(_globalPhase + (particle.seed * 0.35));

      particle.x +=
          (localWave * particle.drift) + (globalWave * particle.drift * 0.35);

      if (pointer != null && screenSize.width > 0 && screenSize.height > 0) {
        final particlePx = particle.x * screenSize.width;
        final particlePy = particle.y * screenSize.height;

        final dx = particlePx - pointer.dx;
        final dy = particlePy - pointer.dy;
        final distance = sqrt((dx * dx) + (dy * dy));

        const influenceRadius = 140.0;

        if (distance < influenceRadius && distance > 0.001) {
          final force = (1 - (distance / influenceRadius)) * 0.0022;
          particle.x += (dx / distance) * force;
          particle.y += (dy / distance) * force;
        }
      }

      if (particle.y > 1.02) {
        particle.y = -0.02;
        particle.x = _random.nextDouble();
        _resetDepthValues(particle);
      }

      if (particle.x < -0.05) {
        particle.x = 1.05;
      } else if (particle.x > 1.05) {
        particle.x = -0.05;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _resetDepthValues(_Particle particle) {
    final depth = _random.nextDouble();
    particle.radius = lerpDouble(0.8, 2.2, depth)!;
    particle.opacity = lerpDouble(0.18, 0.55, depth)!;
    particle.speed = lerpDouble(0.00008, 0.00045, depth)!;
    particle.drift = lerpDouble(0.00002, 0.00010, depth)!;
    particle.seed = _random.nextDouble() * pi * 2;
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_tick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ZeronBackgroundPainter(particles: _particles),
      ),
    );
  }
}

class _ZeronBackgroundPainter extends CustomPainter {
  const _ZeronBackgroundPainter({
    required this.particles,
  });

  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final dx = particle.x * size.width;
      final dy = particle.y * size.height;

      paint.color = Color.fromRGBO(
        255,
        255,
        255,
        particle.opacity,
      );

      canvas.drawCircle(
        Offset(dx, dy),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ZeronBackgroundPainter oldDelegate) {
    return true;
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.speed,
    required this.drift,
    required this.seed,
  });

  double x;
  double y;
  double radius;
  double opacity;
  double speed;
  double drift;
  double seed;
}