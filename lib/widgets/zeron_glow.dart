import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class ZeronGlow extends StatefulWidget {
  const ZeronGlow({
    super.key,
    this.isIdle = false,
  });

  final bool isIdle;

  @override
  State<ZeronGlow> createState() => _ZeronGlowState();
}

class _ZeronGlowState extends State<ZeronGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> glowOpacity;
  late final Animation<double> glowScale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    final curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    glowOpacity = Tween<double>(
      begin: 0.10,
      end: 0.18,
    ).animate(curved);

    glowScale = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(curved);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileLike = screenWidth < 700;

    final glowWidth = isMobileLike ? screenWidth * 0.72 : 320.0;
    final glowHeight = isMobileLike ? screenWidth * 0.24 : 110.0;
    final blurSigma = isMobileLike ? 38.0 : 48.0;

    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final baseOpacity = glowOpacity.value;
            final idleBoost = widget.isIdle ? 0.045 : 0.0;
            final resolvedOpacity = (baseOpacity + idleBoost).clamp(0.0, 1.0);

            final baseScale = glowScale.value;
            final idleScaleBoost = widget.isIdle ? 0.025 : 0.0;

            final t = controller.value * math.pi * 2;
            final driftX = math.sin(t) * 2.2;
            final driftY = math.cos(t * 0.8) * 2.8;
            final idleDriftBoost = widget.isIdle ? 1.35 : 1.0;

            return Transform.translate(
              offset: Offset(
                driftX * idleDriftBoost,
                driftY * idleDriftBoost,
              ),
              child: Transform.scale(
                scale: baseScale + idleScaleBoost,
                child: Opacity(
                  opacity: resolvedOpacity,
                  child: child,
                ),
              ),
            );
          },
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: Container(
              width: glowWidth.clamp(220.0, 360.0),
              height: glowHeight.clamp(70.0, 120.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
    );
  }
}