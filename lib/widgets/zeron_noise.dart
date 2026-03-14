import 'dart:math';
import 'package:flutter/material.dart';

class ZeronNoise extends StatefulWidget {
  const ZeronNoise({super.key});

  @override
  State<ZeronNoise> createState() => _ZeronNoiseState();
}

class _ZeronNoiseState extends State<ZeronNoise>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();

  double _noiseSeed = 0;
  double _phase = 0;

  @override
  void initState() {
    super.initState();

    _noiseSeed = _random.nextDouble();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )
      ..addListener(() {
        setState(() {
          _noiseSeed = _random.nextDouble();
          _phase += 0.0025;
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
        painter: _ZeronNoisePainter(
          noiseSeed: _noiseSeed,
          phase: _phase,
        ),
      ),
    );
  }
}

class _ZeronNoisePainter extends CustomPainter {
  const _ZeronNoisePainter({
    required this.noiseSeed,
    required this.phase,
  });

  final double noiseSeed;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    _paintVignette(canvas, size);
    _paintGlow(canvas, size);
    _paintScanlines(canvas, size);
    _paintNoise(canvas, size);
  }

  void _paintVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: const [
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(0, 0, 0, 0.18),
          Color.fromRGBO(0, 0, 0, 0.42),
        ],
        stops: const [0.45, 0.78, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintGlow(Canvas canvas, Size size) {
    final driftX = sin(phase) * 6;
    final driftY = cos(phase * 0.8) * 4;

    final rect = Rect.fromCenter(
      center: Offset(
        size.width / 2 + driftX,
        size.height / 2 + driftY,
      ),
      width: size.width * 0.42,
      height: size.height * 0.22,
    );

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: const [
          Color.fromRGBO(255, 255, 255, 0.028),
          Color.fromRGBO(255, 255, 255, 0.012),
          Color.fromRGBO(255, 255, 255, 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawOval(rect, paint);
  }

  void _paintScanlines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.038)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _paintNoise(Canvas canvas, Size size) {
    final random = Random((noiseSeed * 100000).floor());
    final paint = Paint()..style = PaintingStyle.fill;

    const cellSize = 3.0;

    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        final value = random.nextDouble();

        if (value > 0.992) {
          paint.color = Color.fromRGBO(
            255,
            255,
            255,
            0.045 + random.nextDouble() * 0.035,
          );

          canvas.drawRect(
            Rect.fromLTWH(x, y, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZeronNoisePainter oldDelegate) {
    return true;
  }
}