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
  final Random _random = Random();
  final List<_Particle> _particles = <_Particle>[];

  Size _lastSize = Size.zero;

  static const int _baseParticleCount = 42;
  static const int _maxAdditionalParticles = 12;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )
      ..addListener(_tick)
      ..forward();

    _generateInitialParticles();
  }

  void _generateInitialParticles() {
    if (_particles.isNotEmpty) return;

    final int total = _targetParticleCount();
    for (int i = 0; i < total; i++) {
      _particles.add(_Particle.random(_random));
    }
  }

  int _targetParticleCount() {
    return (_baseParticleCount +
            (widget.ambientStage * 3) +
            (widget.interactionEnergy * _maxAdditionalParticles).round())
        .clamp(_baseParticleCount, _baseParticleCount + _maxAdditionalParticles);
  }

  void _syncParticleCount() {
    final int target = _targetParticleCount();

    if (_particles.length < target) {
      for (int i = 0; i < target - _particles.length; i++) {
        _particles.add(_Particle.random(_random));
      }
      return;
    }

    if (_particles.length > target) {
      _particles.removeRange(target, _particles.length);
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

  void _tick() {
    _syncParticleCount();

    final Offset pointer = _normalizedPointer();
    final double stageEnergy = (widget.ambientStage / 3.0).clamp(0.0, 1.0);
    final double time = widget.presenceSeconds;

    for (final _Particle particle in _particles) {
      particle.update(
        pointer: pointer,
        interactionEnergy: widget.interactionEnergy,
        stageEnergy: stageEnergy,
        time: time,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _lastSize = Size(constraints.maxWidth, constraints.maxHeight);

        return CustomPaint(
          size: Size.infinite,
          painter: _BackgroundPainter(
            particles: _particles,
            presenceSeconds: widget.presenceSeconds,
            ambientStage: widget.ambientStage,
            interactionEnergy: widget.interactionEnergy,
          ),
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
    required this.depth,
    required this.baseSize,
    required this.baseOpacity,
    required this.phase,
    required this.streamSeed,
    required this.orbitSeed,
    required this.driftDirection,
  });

  double x;
  double y;
  double depth;
  double baseSize;
  double baseOpacity;
  double phase;
  double streamSeed;
  double orbitSeed;
  double driftDirection;

  factory _Particle.random(Random random) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      depth: 0.18 + (random.nextDouble() * 0.82),
      baseSize: 0.5 + (random.nextDouble() * 1.7),
      baseOpacity: 0.035 + (random.nextDouble() * 0.12),
      phase: random.nextDouble() * pi * 2,
      streamSeed: random.nextDouble() * pi * 2,
      orbitSeed: random.nextDouble() * pi * 2,
      driftDirection: random.nextBool() ? 1.0 : -1.0,
    );
  }

  void update({
    required Offset pointer,
    required double interactionEnergy,
    required double stageEnergy,
    required double time,
  }) {
    final double depthSpeed = lerpDouble(0.00022, 0.00145, depth)!;
    y += depthSpeed * (1.0 + stageEnergy * 0.10);

    final double horizontalStream = sin((time * 0.11) + streamSeed + (y * 5.8)) *
        (0.00010 + depth * 0.00018);

    final double orbitalDrift = cos((time * 0.07) + orbitSeed + (x * 4.0)) *
        (0.00004 + depth * 0.00008) *
        driftDirection;

    final double centerPull = ((0.5 - x) * (0.000025 + depth * 0.000045));

    x += horizontalStream + orbitalDrift + centerPull;

    final double dx = x - pointer.dx;
    final double dy = y - pointer.dy;
    final double distance = sqrt((dx * dx) + (dy * dy));

    if (distance < 0.14) {
      final double repulsion = (0.14 - distance) *
          (0.00032 + interactionEnergy * 0.00065) *
          (0.55 + depth * 0.7);

      x += dx * repulsion;
      y += dy * repulsion * 0.22;
    }

    if (x < -0.08) x = 1.08;
    if (x > 1.08) x = -0.08;

    if (y > 1.10) {
      y = -0.10;
      x = 0.14 + Random((phase * 100000).round() + (time * 10).round())
          .nextDouble() * 0.72;
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

    final double breath = (sin(presenceSeconds * 0.16) + 1) * 0.5;
    final double stageBoost = ambientStage * 0.010;

    for (final _Particle particle in particles) {
      final double twinkle = (sin(
                (presenceSeconds * (0.22 + particle.depth * 0.55)) +
                    particle.phase,
              ) +
              1) *
          0.5;

      final double radius = (particle.baseSize *
              (0.55 + particle.depth * 1.35) +
              (twinkle * 0.16) +
              (interactionEnergy * 0.08))
          .clamp(0.35, 2.7);

      final double opacity = (particle.baseOpacity +
              (twinkle * 0.030) +
              (breath * 0.014) +
              stageBoost +
              (interactionEnergy * 0.028))
          .clamp(0.025, 0.20);

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
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}