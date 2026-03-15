import 'dart:math' as math;
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
  late final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> opacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    final curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    scale = Tween<double>(
      begin: 0.988,
      end: 1.028,
    ).animate(curved);

    opacity = Tween<double>(
      begin: 0.84,
      end: 1.0,
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

    final fontSize = isMobileLike ? screenWidth * 0.105 : 40.0;

    final letterSpacing = isMobileLike ? screenWidth * 0.02 : 8.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final idleOpacityOffset = widget.isIdle ? -0.16 : 0.0;

        final resolvedOpacity =
        (opacity.value + idleOpacityOffset).clamp(0.0, 1.0);

        final t = controller.value * math.pi * 2;

        final driftX = math.sin(t) * 2.0;

        final driftY = math.cos(t * 0.85) * 2.6;

        final idleDriftBoost = widget.isIdle ? 1.45 : 1.0;

        return Transform.translate(
          offset: Offset(
            driftX * idleDriftBoost,
            driftY * idleDriftBoost,
          ),
          child: Opacity(
            opacity: resolvedOpacity,
            child: Transform.scale(
              scale: scale.value,
              child: child,
            ),
          ),
        );
      },
      child: Text(
        'ZERON',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize.clamp(30.0, 48.0),
          letterSpacing: letterSpacing.clamp(5.0, 10.0),
          fontWeight: FontWeight.w300,
          shadows: const [
            Shadow(
              color: Color.fromRGBO(255, 255, 255, 0.22),
              blurRadius: 14,
            ),
            Shadow(
              color: Color.fromRGBO(255, 255, 255, 0.1),
              blurRadius: 28,
            ),
          ],
        ),
      ),
    );
  }
}