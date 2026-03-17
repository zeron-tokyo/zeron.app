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

  static const int _baseParticleCount = 90;
  static const int _maxAdditionalParticles = 50;

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
        _baseParticleCount + (widget.ambientStage * 8);

    for (int i = 0; i < total; i++) {
      _particles.add(_Particle.random(_random));
    }
  }

  void _syncParticleCount() {
    final int targetCount = (_baseParticleCount +
            (widget.ambientStage * 8) +
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

    final Offset pointer = _normalizedPointer();

    final double drift = sin(widget.presenceSeconds * 0.10) * 0.5 + 0.5;
    final double breath = sin(widget.presenceSeconds * 0.22) * 0.5 + 0.5;
    final double stageEnergy = (widget.ambientStage / 3.0).clamp(0.0, 1.0);

    for (final _Particle p in _particles) {
      p.update(
        pointer: pointer,
        drift: drift,
        breath: breath,
        interactionEnergy: widget.interactionEnergy,
        stageEnergy: stageEnergy,
        presenceSeconds: widget.presenceSeconds,
      );
    }

    if (mounted) setState(() {});
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
      builder: (context, constraints) {
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

  factory _Particle.random(Random r) {
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble(),
      vx: (r.nextDouble() - 0.5) * 0.0012,
      vy: (r.nextDouble() - 0.5) * 0.0012,
      size: 0.5 + (r.nextDouble() * 2.2),
      opacity: 0.06 + (r.nextDouble() * 0.22),
      depth: 0.4 + (r.nextDouble() * 0.8),
      seed: r.nextDouble() * pi * 2,
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
    final double flowX =
        sin((y * 6.0) + (presenceSeconds * 0.08) + seed) *
            0.00015 *
            (0.6 + depth);

    final double flowY =
        cos((x * 5.0) - (presenceSeconds * 0.07) + seed) *
            0.00012 *
            (0.6 + depth);

    vx += flowX;
    vy += flowY;

    vx += (drift - 0.5) * 0.00008 * depth;
    vy += (breath - 0.5) * 0.00005 * depth;

    final dx = x - pointer.dx;
    final dy = y - pointer.dy;
    final dist = sqrt(dx * dx + dy * dy);

    if (dist < 0.18) {
      final force =
          (0.18 - dist) * (0.0006 + interactionEnergy * 0.0012);
      vx += dx * force * depth;
      vy += dy * force * depth;
    }

    final limit =
        0.0016 + (interactionEnergy * 0.0025) + (stageEnergy * 0.001);
    vx = vx.clamp(-limit, limit);
    vy = vy.clamp(-limit, limit);

    x += vx;
    y += vy;

    vx *= 0.994;
    vy *= 0.994;

    if (x < -0.05) x = 1.05;
    if (x > 1.05) x = -0.05;
    if (y < -0.05) y = 1.05;
    if (y > 1.05) y = -0.05;
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
    final paint = Paint()..style = PaintingStyle.fill;

    final double breath = sin(presenceSeconds * 0.18) * 0.5 + 0.5;
    final double stageBoost = ambientStage * 0.03;

    for (final p in particles) {
      final double pulse =
          sin((presenceSeconds * (0.4 + p.depth * 0.2)) + p.seed) *
                  0.5 +
              0.5;

      final double opacity = (p.opacity +
              (pulse * 0.05) +
              (breath * 0.04) +
              (interactionEnergy * 0.10) +
              stageBoost)
          .clamp(0.03, 0.45);

      final double radius = (p.size +
              (pulse * 0.4) +
              (interactionEnergy * 0.5) +
              (ambientStage * 0.1))
          .clamp(0.3, 3.8);

      paint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) {
    return true;
  }
}