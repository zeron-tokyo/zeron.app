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

  static const int _baseParticleCount = 58;
  static const int _maxAdditionalParticles = 18;

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
            (widget.ambientStage * 4) +
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
    required this.baseSpeed,
    required this.depth,
    required this.size,
    required this.opacity,
    required this.seed,
    required this.driftSeed,
  });

  double x;
  double y;
  double baseSpeed;
  double depth;
  double size;
  double opacity;
  double seed;
  double driftSeed;

  factory _Particle.random(Random random) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble() * 1.2 - 0.1,
      baseSpeed: 0.00016 + (random.nextDouble() * 0.00034),
      depth: 0.45 + (random.nextDouble() * 1.5),
      size: 0.55 + (random.nextDouble() * 1.8),
      opacity: 0.045 + (random.nextDouble() * 0.14),
      seed: random.nextDouble() * pi * 2,
      driftSeed: random.nextDouble() * pi * 2,
    );
  }

  void update({
    required Offset pointer,
    required double interactionEnergy,
    required double stageEnergy,
    required double time,
  }) {
    final double verticalSpeed =
        baseSpeed * (0.88 + depth * 0.72) * (1.0 + stageEnergy * 0.18);

    y += verticalSpeed;

    final double stream =
        sin((time * 0.12) + driftSeed + (y * 4.0)) * 0.00012 * depth;

    final double orbital =
        cos((time * 0.08) + seed + (y * 2.8)) * 0.00005 * (0.6 + depth);

    x += stream + orbital;

    final double dx = x - pointer.dx;
    final double dy = y - pointer.dy;
    final double distance = sqrt((dx * dx) + (dy * dy));

    if (distance < 0.16) {
      final double influence = (0.16 - distance) *
          (0.00055 + interactionEnergy * 0.0009) *
          (0.7 + depth * 0.4);

      x += dx * influence;
      y += dy * influence * 0.45;
    }

    if (x < -0.08) x = 1.08;
    if (x > 1.08) x = -0.08;

    if (y > 1.08) {
      y = -0.10;
      x = (x + 0.08 + sin(seed + time * 0.03) * 0.06) % 1.0;
      if (x < 0) x += 1.0;
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

    final double breath = (sin(presenceSeconds * 0.18) + 1) * 0.5;
    final double stageBoost = ambientStage * 0.012;

    for (final _Particle particle in particles) {
      final double pulse = (sin(
                (presenceSeconds * (0.28 + particle.depth * 0.12)) +
                    particle.seed,
              ) +
              1) *
          0.5;

      final double opacity = (particle.opacity +
              (pulse * 0.035) +
              (breath * 0.018) +
              (interactionEnergy * 0.05) +
              stageBoost)
          .clamp(0.025, 0.22);

      final double radius = (particle.size *
              (0.8 + particle.depth * 0.58) +
              (pulse * 0.28) +
              (interactionEnergy * 0.22))
          .clamp(0.45, 3.2);

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