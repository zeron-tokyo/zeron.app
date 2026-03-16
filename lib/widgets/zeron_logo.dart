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
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isIdle ? 4200 : 2800),
    )..repeat(reverse: true);

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scale = Tween<double>(
      begin: widget.isIdle ? 0.992 : 0.986,
      end: widget.isIdle ? 1.008 : 1.022,
    ).animate(curved);

    _opacity = Tween<double>(
      begin: widget.isIdle ? 0.90 : 0.84,
      end: 1.0,
    ).animate(curved);

    _glowOpacity = Tween<double>(
      begin: widget.isIdle ? 0.10 : 0.14,
      end: widget.isIdle ? 0.18 : 0.24,
    ).animate(curved);

    _floatY = Tween<double>(
      begin: widget.isIdle ? 1.5 : 2.0,
      end: widget.isIdle ? -1.5 : -2.0,
    ).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _logoSize(double screenWidth) {
    if (screenWidth >= 1400) return 220;
    if (screenWidth >= 1000) return 180;
    if (screenWidth >= 700) return 150;
    return screenWidth * 0.34;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = _logoSize(screenWidth);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _floatY.value),
            child: Transform.scale(
              scale: _scale.value,
              child: SizedBox(
                width: logoSize,
                height: logoSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: _glowOpacity.value,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 20,
                          sigmaY: 20,
                        ),
                        child: Image.asset(
                          'assets/brand/zeron_symbol_white.png',
                          width: logoSize * 0.92,
                          height: logoSize * 0.92,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: _glowOpacity.value * 0.55,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 42,
                          sigmaY: 42,
                        ),
                        child: Image.asset(
                          'assets/brand/zeron_symbol_white.png',
                          width: logoSize * 1.02,
                          height: logoSize * 1.02,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/brand/zeron_symbol_white.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}