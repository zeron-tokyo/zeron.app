import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ZeronGlobe extends StatefulWidget {
  const ZeronGlobe({
    super.key,
    required this.progress,
    required this.globalEnergy,
    required this.participationDensity,
    required this.userEnergy,
    required this.languageJa,
    this.size = 320,
    this.onHotspotChanged,
  });

  final double progress;
  final double globalEnergy;
  final double participationDensity;
  final double userEnergy;
  final bool languageJa;
  final double size;
  final ValueChanged<int>? onHotspotChanged;

  @override
  State<ZeronGlobe> createState() => _ZeronGlobeState();
}

class _ZeronGlobeState extends State<ZeronGlobe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _yaw = -0.35;
  double _pitch = -0.12;
  double _yawVelocity = 0.0;
  double _pitchVelocity = 0.0;
  double _scale = 1.0;
  double _gestureStartScale = 1.0;

  Timer? _inertiaTimer;
  int _selectedHotspot = 0;

  static const List<_HotspotMeta> _hotspots = <_HotspotMeta>[
    _HotspotMeta(
      en: 'Your activity area',
      ja: 'あなたの活動エリア',
      label: 'YOU',
    ),
    _HotspotMeta(
      en: 'Team contribution zone',
      ja: 'チーム貢献エリア',
      label: 'TEAM',
    ),
    _HotspotMeta(
      en: 'Company participation zone',
      ja: 'カンパニー参加エリア',
      label: 'COMPANY',
    ),
    _HotspotMeta(
      en: 'World participation density',
      ja: '世界参加密度',
      label: 'WORLD',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _inertiaTimer?.cancel();
    super.dispose();
  }

  void _startInertia() {
    _inertiaTimer?.cancel();
    _inertiaTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;

      setState(() {
        _yaw += _yawVelocity;
        _pitch += _pitchVelocity;

        _yawVelocity *= 0.95;
        _pitchVelocity *= 0.93;
        _pitch = _pitch.clamp(-1.1, 1.1);

        if (_yawVelocity.abs() < 0.0002 && _pitchVelocity.abs() < 0.0002) {
          _inertiaTimer?.cancel();
        }
      });
    });
  }

  void _selectNextHotspot() {
    setState(() {
      _selectedHotspot = (_selectedHotspot + 1) % _hotspots.length;
    });
    widget.onHotspotChanged?.call(_selectedHotspot);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _selectNextHotspot,
      onScaleStart: (_) {
        _gestureStartScale = _scale;
        _inertiaTimer?.cancel();
      },
      onScaleUpdate: (details) {
        setState(() {
          if (details.pointerCount > 1) {
            _scale = (_gestureStartScale * details.scale).clamp(0.82, 1.95);
          } else {
            _yawVelocity = details.focalPointDelta.dx * 0.0048;
            _pitchVelocity = details.focalPointDelta.dy * 0.0038;
            _yaw += _yawVelocity;
            _pitch = (_pitch + _pitchVelocity).clamp(-1.1, 1.1);
          }
        });
      },
      onScaleEnd: (_) => _startInertia(),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final autoSpin = _controller.value * math.pi * 2.0;
            return CustomPaint(
              painter: _ZeronGlobePainter(
                yaw: _yaw + autoSpin,
                pitch: _pitch,
                scale: _scale,
                progress: widget.progress.clamp(0.0, 1.0),
                globalEnergy: widget.globalEnergy.clamp(0.0, 1.0),
                participationDensity:
                    widget.participationDensity.clamp(0.0, 1.0),
                userEnergy: widget.userEnergy.clamp(0.0, 1.0),
                shimmer: _controller.value,
                selectedHotspot: _selectedHotspot,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HotspotMeta {
  const _HotspotMeta({
    required this.en,
    required this.ja,
    required this.label,
  });

  final String en;
  final String ja;
  final String label;
}

class _ProjectedPoint {
  const _ProjectedPoint({
    required this.offset,
    required this.depth,
    required this.visible,
  });

  final Offset offset;
  final double depth;
  final bool visible;
}

class _ZeronGlobePainter extends CustomPainter {
  _ZeronGlobePainter({
    required this.yaw,
    required this.pitch,
    required this.scale,
    required this.progress,
    required this.globalEnergy,
    required this.participationDensity,
    required this.userEnergy,
    required this.shimmer,
    required this.selectedHotspot,
  });

  final double yaw;
  final double pitch;
  final double scale;
  final double progress;
  final double globalEnergy;
  final double participationDensity;
  final double userEnergy;
  final double shimmer;
  final int selectedHotspot;

  static const Color _mint = Color(0xFFB8FFE3);
  static const Color _cyan = Color(0xFF4CB9FF);
  static const Color _deep1 = Color(0xFF02070B);
  static const Color _deep2 = Color(0xFF08141B);
  static const Color _deep3 = Color(0xFF14303A);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.38 * scale;
    final sphereRect = Rect.fromCircle(center: center, radius: radius);

    final outerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _mint.withOpacity(0.10 + userEnergy * 0.10),
          _cyan.withOpacity(0.06 + globalEnergy * 0.08),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 1.95),
      );

    canvas.drawCircle(center, radius * 1.9, outerGlowPaint);

    final haloPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withOpacity(0.08);

    canvas.drawCircle(center, radius * 1.18, haloPaint);

    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          -0.30 + math.cos(yaw * 0.65) * 0.08,
          -0.34 + math.sin(yaw * 0.50) * 0.06,
        ),
        radius: 1.08,
        colors: [
          _deep3,
          _deep2,
          _deep1,
        ],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(sphereRect);

    canvas.drawCircle(center, radius, spherePaint);

    canvas.save();
    canvas.clipPath(Path()..addOval(sphereRect));

    _paintNightShade(canvas, center, radius);
    _paintGrid(canvas, center, radius);
    _paintContinents(canvas, center, radius);
    _paintAtmosphericCloud(canvas, center, radius);
    _paintActivityPoints(canvas, center, radius);

    canvas.restore();

    _paintAtmosphereRim(canvas, center, radius);
    _paintProgressRing(canvas, center, radius);
  }

  void _paintNightShade(Canvas canvas, Offset center, double radius) {
    final shadeCenter = Offset(
      center.dx + math.cos(yaw + math.pi) * radius * 0.34,
      center.dy + math.sin(pitch) * radius * 0.12,
    );

    final shadePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.05),
          Colors.black.withOpacity(0.18),
        ],
        stops: const [0.20, 0.68, 1.0],
      ).createShader(
        Rect.fromCircle(center: shadeCenter, radius: radius * 1.2),
      );

    canvas.drawCircle(center, radius, shadePaint);
  }

  void _paintGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Colors.white.withOpacity(0.05 + participationDensity * 0.05);

    for (int lat = -60; lat <= 60; lat += 20) {
      final points = <Offset>[];
      for (int lon = -180; lon <= 180; lon += 4) {
        final p = _project(
          latDeg: lat.toDouble(),
          lonDeg: lon.toDouble(),
          center: center,
          radius: radius,
        );
        if (p.visible) {
          points.add(p.offset);
        }
      }
      _drawPolyline(canvas, points, gridPaint);
    }

    for (int lon = -150; lon <= 180; lon += 30) {
      final points = <Offset>[];
      for (int lat = -85; lat <= 85; lat += 3) {
        final p = _project(
          latDeg: lat.toDouble(),
          lonDeg: lon.toDouble(),
          center: center,
          radius: radius,
        );
        if (p.visible) {
          points.add(p.offset);
        }
      }
      _drawPolyline(canvas, points, gridPaint);
    }
  }

  void _paintContinents(Canvas canvas, Offset center, double radius) {
    final continentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _mint.withOpacity(0.15 + shimmer * 0.04);

    final coastPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withOpacity(0.10);

    final shapes = <List<Offset>>[
      const <Offset>[
        Offset(-165, 60),
        Offset(-140, 72),
        Offset(-112, 66),
        Offset(-95, 52),
        Offset(-82, 28),
        Offset(-100, 12),
        Offset(-115, -8),
        Offset(-105, -28),
        Offset(-80, -50),
        Offset(-62, -28),
        Offset(-70, 5),
        Offset(-92, 24),
        Offset(-124, 36),
        Offset(-152, 48),
      ],
      const <Offset>[
        Offset(-12, 70),
        Offset(24, 64),
        Offset(60, 54),
        Offset(98, 56),
        Offset(126, 48),
        Offset(142, 30),
        Offset(124, 12),
        Offset(102, 8),
        Offset(82, 22),
        Offset(56, 26),
        Offset(42, 12),
        Offset(26, -6),
        Offset(14, -20),
        Offset(26, -34),
        Offset(16, -36),
        Offset(0, -24),
        Offset(-10, 2),
        Offset(-6, 28),
      ],
      const <Offset>[
        Offset(110, -10),
        Offset(130, -18),
        Offset(148, -26),
        Offset(154, -38),
        Offset(142, -44),
        Offset(124, -40),
        Offset(112, -28),
      ],
      const <Offset>[
        Offset(-54, 76),
        Offset(-34, 80),
        Offset(-20, 72),
        Offset(-30, 64),
        Offset(-48, 66),
      ],
    ];

    for (final shape in shapes) {
      final projected = <Offset>[];
      for (final ll in shape) {
        final p = _project(
          lonDeg: ll.dx,
          latDeg: ll.dy,
          center: center,
          radius: radius,
        );
        if (p.visible) {
          projected.add(p.offset);
        }
      }
      if (projected.length >= 3) {
        final path = Path()..addPolygon(projected, true);
        canvas.drawPath(path, continentPaint);
        canvas.drawPath(path, coastPaint);
      }
    }
  }

  void _paintAtmosphericCloud(Canvas canvas, Offset center, double radius) {
    final cloudPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _cyan.withOpacity(0.03 + globalEnergy * 0.04),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            center.dx - radius * 0.10,
            center.dy - radius * 0.12,
          ),
          radius: radius * 0.95,
        ),
      );

    canvas.drawCircle(center, radius, cloudPaint);
  }

  void _paintActivityPoints(Canvas canvas, Offset center, double radius) {
    final seeds = <_ActivitySeed>[
      const _ActivitySeed(lat: 35.68, lon: 139.76, type: 0),
      const _ActivitySeed(lat: 34.69, lon: 135.50, type: 1),
      const _ActivitySeed(lat: 37.77, lon: -122.42, type: 2),
      const _ActivitySeed(lat: 51.50, lon: -0.12, type: 3),
      const _ActivitySeed(lat: 48.85, lon: 2.35, type: 3),
      const _ActivitySeed(lat: 1.29, lon: 103.85, type: 2),
      const _ActivitySeed(lat: -33.86, lon: 151.20, type: 1),
      const _ActivitySeed(lat: 25.20, lon: 55.27, type: 2),
    ];

    for (int i = 0; i < seeds.length; i++) {
      final seed = seeds[i];
      final p = _project(
        latDeg: seed.lat,
        lonDeg: seed.lon,
        center: center,
        radius: radius,
      );

      if (!p.visible) continue;

      final wave = (math.sin((shimmer * math.pi * 2.0 * 2.0) + i) * 0.5 + 0.5);
      final activeBoost = selectedHotspot == seed.type ? 1.0 : 0.0;

      final glowRadius =
          radius * (0.018 + wave * 0.010 + activeBoost * 0.010) * p.depth;
      final coreRadius =
          radius * (0.006 + wave * 0.004 + activeBoost * 0.003) * p.depth;

      final glowColor = switch (seed.type) {
        0 => _mint,
        1 => const Color(0xFF93F7FF),
        2 => const Color(0xFF73C8FF),
        _ => Colors.white,
      };

      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..color = glowColor.withOpacity(
          0.16 + wave * 0.18 + activeBoost * 0.14,
        );

      final corePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = glowColor.withOpacity(0.80);

      canvas.drawCircle(p.offset, glowRadius, glowPaint);
      canvas.drawCircle(p.offset, coreRadius, corePaint);
    }
  }

  void _paintAtmosphereRim(Canvas canvas, Offset center, double radius) {
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = SweepGradient(
        colors: [
          _mint.withOpacity(0.10),
          _cyan.withOpacity(0.26 + globalEnergy * 0.12),
          _mint.withOpacity(0.14 + progress * 0.10),
          _mint.withOpacity(0.10),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius + 1, rimPaint);
  }

  void _paintProgressRing(Canvas canvas, Offset center, double radius) {
    final ringRect = Rect.fromCircle(center: center, radius: radius * 1.33);

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.08);

    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: const <Color>[
          _mint,
          _cyan,
          _mint,
        ],
      ).createShader(ringRect);

    canvas.drawArc(ringRect, -math.pi / 2, math.pi * 2, false, bgPaint);
    canvas.drawArc(
      ringRect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      fgPaint,
    );
  }

  _ProjectedPoint _project({
    required double latDeg,
    required double lonDeg,
    required Offset center,
    required double radius,
  }) {
    final lat = latDeg * math.pi / 180.0;
    final lon = lonDeg * math.pi / 180.0;

    final x0 = math.cos(lat) * math.sin(lon);
    final y0 = math.sin(lat);
    final z0 = math.cos(lat) * math.cos(lon);

    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);
    final x1 = x0 * cosYaw + z0 * sinYaw;
    final z1 = -x0 * sinYaw + z0 * cosYaw;

    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    final y2 = y0 * cosPitch - z1 * sinPitch;
    final z2 = y0 * sinPitch + z1 * cosPitch;

    final visible = z2 > 0.0;

    final perspective = 0.72 + z2 * 0.28;
    final dx = center.dx + x1 * radius * perspective;
    final dy = center.dy - y2 * radius * perspective;

    return _ProjectedPoint(
      offset: Offset(dx, dy),
      depth: (0.72 + z2 * 0.28).clamp(0.0, 1.3),
      visible: visible,
    );
  }

  void _drawPolyline(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ZeronGlobePainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.scale != scale ||
        oldDelegate.progress != progress ||
        oldDelegate.globalEnergy != globalEnergy ||
        oldDelegate.participationDensity != participationDensity ||
        oldDelegate.userEnergy != userEnergy ||
        oldDelegate.shimmer != shimmer ||
        oldDelegate.selectedHotspot != selectedHotspot;
  }
}

class _ActivitySeed {
  const _ActivitySeed({
    required this.lat,
    required this.lon,
    required this.type,
  });

  final double lat;
  final double lon;
  final int type;
}