import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class ZeronLogo extends StatefulWidget {
  const ZeronLogo({
    super.key,
    this.isIdle = false,
  });

  final bool isIdle;

  @override
  State<ZeronLogo> createState() => _ZeronLogoState();
}

class _ZeronLogoState extends State<ZeronLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const String _assetPath = 'assets/brand/zeron_symbol_white.png';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isIdle ? 6200 : 4200),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant ZeronLogo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isIdle != widget.isIdle) {
      _controller.duration =
          Duration(milliseconds: widget.isIdle ? 6200 : 4200);

      _controller
        ..reset()
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _logoSize(double width) {
    if (width >= 1600) return 220;
    if (width >= 1300) return 198;
    if (width >= 1000) return 176;
    if (width >= 700) return 148;
    return width * 0.34;
  }

  @override
  Widget build(BuildContext context) {
    final double size = _logoSize(MediaQuery.of(context).size.width);

    return RepaintBoundary( // ★パフォーマンス安定
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final double t = _controller.value;

          final double scale =
              widget.isIdle ? (0.992 + t * 0.018) : (0.982 + t * 0.042);

          final double opacity =
              widget.isIdle ? (0.94 + t * 0.06) : (0.90 + t * 0.10);

          final double drift =
              (math.sin(t * math.pi * 2) *
                  (widget.isIdle ? 1.8 : 2.8));

          final double glowStrength =
              widget.isIdle ? 0.12 + t * 0.10 : 0.18 + t * 0.20;

          final double shimmer =
              (math.sin(t * math.pi * 2) + 1.0) * 0.5;

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, drift * 0.4),
              child: Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: size * 1.25,
                  height: size * 1.25,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      // ===== 外側の存在感 =====
                      Opacity(
                        opacity: glowStrength * 0.8,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: widget.isIdle ? 42 : 52,
                            sigmaY: widget.isIdle ? 42 : 52,
                          ),
                          child: Image.asset(
                            _assetPath,
                            width: size * 1.25,
                            height: size * 1.25,
                          ),
                        ),
                      ),

                      // ===== 中間の光 =====
                      Opacity(
                        opacity: glowStrength,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: widget.isIdle ? 18 : 26,
                            sigmaY: widget.isIdle ? 18 : 26,
                          ),
                          child: Image.asset(
                            _assetPath,
                            width: size * 1.05,
                            height: size * 1.05,
                          ),
                        ),
                      ),

                      // ===== コア =====
                      Image.asset(
                        _assetPath,
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),

                      // ===== シマー（高級感）=====
                      ClipRect(
                        child: SizedBox(
                          width: size * 1.05,
                          height: size * 1.05,
                          child: Transform.translate(
                            offset: Offset(
                                drift * (widget.isIdle ? 0.6 : 1.0), 0),
                            child: Opacity(
                              opacity: (widget.isIdle ? 0.05 : 0.10) +
                                  shimmer * 0.05,
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: ShaderMask(
                                  blendMode: BlendMode.srcATop,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.9),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.3, 0.5, 0.7],
                                    ).createShader(bounds);
                                  },
                                  child: Image.asset(
                                    _assetPath,
                                    width: size,
                                    height: size,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}