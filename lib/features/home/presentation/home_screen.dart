// 変更点だけじゃなく完全体で出す（そのまま貼り替え）

import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zeron/widgets/zeron_background.dart';
import 'package:zeron/widgets/zeron_distortion.dart';
import 'package:zeron/widgets/zeron_glow.dart';
import 'package:zeron/widgets/zeron_logo.dart';
import 'package:zeron/widgets/zeron_noise.dart';

class ZeronHomeScreen extends StatefulWidget {
  const ZeronHomeScreen({super.key});

  @override
  State<ZeronHomeScreen> createState() => _ZeronHomeScreenState();
}

class _ZeronHomeScreenState extends State<ZeronHomeScreen>
    with WidgetsBindingObserver {
  static const Duration _tickRate = Duration(milliseconds: 40);

  Timer? _ticker;

  Duration _presence = Duration.zero;
  Duration _bootTime = Duration.zero;

  double _bootProgress = 0.0;

  Offset _pointerPosition = Offset.zero;
  Offset _pointerTarget = Offset.zero;

  bool _isPointerInside = false;
  bool _isIdle = false;
  bool _appActive = true;

  double _interactionEnergy = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _ticker = Timer.periodic(_tickRate, _onTick);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
  }

  void _onTick(Timer timer) {
    if (!mounted || !_appActive) return;

    _presence += _tickRate;
    _bootTime += _tickRate;

    // ===== 起動進行（4秒で完了）=====
    _bootProgress =
        (_bootTime.inMilliseconds / 4000).clamp(0.0, 1.0);

    _interactionEnergy =
        (_interactionEnergy - 0.02).clamp(0.0, 1.0);

    _pointerPosition =
        Offset.lerp(_pointerPosition, _pointerTarget, 0.08) ??
            _pointerPosition;

    _isIdle = _interactionEnergy < 0.02;

    setState(() {});
  }

  void _registerInteraction(Offset pos) {
    _interactionEnergy =
        (_interactionEnergy + 0.08).clamp(0.0, 1.0);
    _pointerTarget = pos;
  }

  void _onPointerHover(PointerHoverEvent e) {
    _isPointerInside = true;
    _registerInteraction(e.localPosition);
  }

  void _onPointerMove(PointerMoveEvent e) {
    _isPointerInside = true;
    _registerInteraction(e.localPosition);
  }

  void _onPointerDown(PointerDownEvent e) {
    _isPointerInside = true;
    _registerInteraction(e.localPosition);
  }

  void _onPointerExit(PointerExitEvent e) {
    _isPointerInside = false;
  }

  @override
  Widget build(BuildContext context) {
    final double p = _bootProgress;

    // ===== 出現制御 =====
    final double noiseOpacity = p < 0.2 ? 1.0 : 1.0;
    final double bgOpacity = (p - 0.2).clamp(0.0, 1.0);
    final double distortionOpacity = (p - 0.4).clamp(0.0, 1.0);
    final double logoOpacity = (p - 0.65).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
        onPointerHover: _onPointerHover,
        onPointerMove: _onPointerMove,
        onPointerDown: _onPointerDown,
        child: MouseRegion(
          onExit: _onPointerExit,
          child: Stack(
            fit: StackFit.expand,
            children: [

              // ===== ノイズ（最初から）=====
              Opacity(
                opacity: noiseOpacity,
                child: ZeronNoise(
                  presenceSeconds: _presence.inMilliseconds / 1000,
                  ambientStage: 0,
                  interactionEnergy: _interactionEnergy,
                  isPointerInside: _isPointerInside,
                ),
              ),

              // ===== 背景（遅れて出現）=====
              Opacity(
                opacity: bgOpacity,
                child: ZeronBackground(
                  presenceSeconds: _presence.inMilliseconds / 1000,
                  ambientStage: 0,
                  interactionEnergy: _interactionEnergy,
                  pointerPosition: _pointerPosition,
                ),
              ),

              // ===== 歪み =====
              Opacity(
                opacity: distortionOpacity,
                child: ZeronDistortion(
                  presenceSeconds: _presence.inMilliseconds / 1000,
                  ambientStage: 0,
                  interactionEnergy: _interactionEnergy,
                  pointerPosition: _pointerPosition,
                ),
              ),

              // ===== ロゴ（最後に出現）=====
              Center(
                child: Opacity(
                  opacity: logoOpacity,
                  child: ZeronLogo(isIdle: _isIdle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}