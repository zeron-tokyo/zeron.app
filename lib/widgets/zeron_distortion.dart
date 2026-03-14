import 'dart:math';
import 'package:flutter/material.dart';

class ZeronDistortion extends StatefulWidget {
  const ZeronDistortion({
    super.key,
    this.intensity = 1.0,
  });

  final double intensity;

  @override
  State<ZeronDistortion> createState() => _ZeronDistortionState();
}

class _ZeronDistortionState extends State<ZeronDistortion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();

  double _phase = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    )
      ..addListener(() {
        setState(() {
          _phase += 0.12 + _random.nextDouble() * 0.08;
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ZeronDistortionPainter(
          phase: _phase,
          intensity: widget.intensity,
        ),
      ),
    );
  }
}

class _ZeronDistortionPainter extends CustomPainter {
  const _ZeronDistortionPainter({
    required this.phase,
    required this.intensity,
  });

  final double phase;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.5;
    final bandHalfHeight = size.height * 0.18;

    for (double y = 0; y < size.height; y += 3) {
      final distance = (y - centerY).abs();
      if (distance > bandHalfHeight) continue;

      final falloff = 1.0 - (distance / bandHalfHeight);

      final wave =
          sin((y * 0.045) + phase) * 6.0 +
              sin((y * 0.018) + phase * 1.7) * 3.0;

      final offsetX = wave * falloff * 0.35 * intensity;

      final opacity = (0.018 + (falloff * 0.025)) * intensity;

      final paint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, opacity.clamp(0, 1))
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(offsetX, y),
        Offset(size.width + offsetX, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ZeronDistortionPainter oldDelegate) {
    return true;
  }
}