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
  late final Animation<double> _glow;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isIdle ? 5200 : 3200),
    )..repeat(reverse: true);

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scale = Tween<double>(
      begin: widget.isIdle ? 0.996 : 0.99,
      end: widget.isIdle ? 1.004 : 1.015,
    ).animate(curved);

    _opacity = Tween<double>(
      begin: widget.isIdle ? 0.92 : 0.86,
      end: 1.0,
    ).animate(curved);

    _glow = Tween<double>(
      begin: widget.isIdle ? 0.06 : 0.10,
      end: widget.isIdle ? 0.12 : 0.18,
    ).animate(curved);

    _float = Tween<double>(
      begin: widget.isIdle ? 1.0 : 1.6,
      end: widget.isIdle ? -1.0 : -1.6,
    ).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _logoSize(double w) {
    if (w >= 1400) return 200;
    if (w >= 1000) return 170;
    if (w >= 700) return 140;
    return w * 0.32;
  }

  @override
  Widget build(BuildContext context) {
    final size = _logoSize(MediaQuery.of(context).size.width);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _float.value),
            child: Transform.scale(
              scale: _scale.value,
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 外側の薄い拡散光（超弱）
                    Opacity(
                      opacity: _glow.value * 0.6,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 36,
                          sigmaY: 36,
                        ),
                        child: Image.asset(
                          'assets/brand/zeron_symbol_white.png',
                          width: size * 1.05,
                          height: size * 1.05,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // 内側のコア発光（軽め）
                    Opacity(
                      opacity: _glow.value,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 16,
                          sigmaY: 16,
                        ),
                        child: Image.asset(
                          'assets/brand/zeron_symbol_white.png',
                          width: size * 0.94,
                          height: size * 0.94,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // 本体（シャープ）
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
          ),
        );
      },
    );
  }
}