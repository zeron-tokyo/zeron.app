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
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _glow;
  late Animation<double> _coreGlow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _configureAnimations();
    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant ZeronLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isIdle != widget.isIdle) {
      _configureAnimations();
      _controller
        ..reset()
        ..repeat(reverse: true);
    }
  }

  void _configureAnimations() {
    final int durationMs = widget.isIdle ? 5600 : 4200;

    _controller.duration = Duration(milliseconds: durationMs);

    final CurvedAnimation curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _scale = Tween<double>(
      begin: widget.isIdle ? 0.986 : 0.978,
      end: widget.isIdle ? 1.014 : 1.026,
    ).animate(curved);

    _opacity = Tween<double>(
      begin: widget.isIdle ? 0.93 : 0.89,
      end: 1.0,
    ).animate(curved);

    _glow = Tween<double>(
      begin: widget.isIdle ? 0.085 : 0.11,
      end: widget.isIdle ? 0.17 : 0.24,
    ).animate(curved);

    _coreGlow = Tween<double>(
      begin: widget.isIdle ? 0.14 : 0.18,
      end: widget.isIdle ? 0.26 : 0.34,
    ).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _logoSize(double width) {
    if (width >= 1600) return 214;
    if (width >= 1300) return 192;
    if (width >= 1000) return 172;
    if (width >= 700) return 144;
    return width * 0.34;
  }

  @override
  Widget build(BuildContext context) {
    final double size = _logoSize(MediaQuery.of(context).size.width);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: _glow.value * 0.42,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: widget.isIdle ? 34 : 40,
                        sigmaY: widget.isIdle ? 34 : 40,
                      ),
                      child: Image.asset(
                        'assets/brand/zeron_symbol_white.png',
                        width: size * 1.16,
                        height: size * 1.16,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: _glow.value,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: widget.isIdle ? 18 : 22,
                        sigmaY: widget.isIdle ? 18 : 22,
                      ),
                      child: Image.asset(
                        'assets/brand/zeron_symbol_white.png',
                        width: size * 1.03,
                        height: size * 1.03,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: _coreGlow.value,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 8,
                        sigmaY: 8,
                      ),
                      child: Image.asset(
                        'assets/brand/zeron_symbol_white.png',
                        width: size * 0.95,
                        height: size * 0.95,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/brand/zeron_symbol_white.png',
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}