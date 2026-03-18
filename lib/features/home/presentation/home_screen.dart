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
  Duration _timeSinceInteraction = Duration.zero;

  int _ambientStage = 0;
  double _interactionEnergy = 0.0;

  Offset _pointerPosition = Offset.zero;
  Offset _pointerTarget = Offset.zero;

  bool _isPointerInside = false;
  bool _didBoot = false;
  bool _isIdle = false;
  bool _appActive = true;

  double _ambientBreath = 0.0;
  double _ambientDrift = 0.0;
  double _ambientPulse = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _didBoot = true;
      });
    });

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
    _timeSinceInteraction += _tickRate;

    final double t = _presence.inMilliseconds / 1000.0;
    final double deltaSeconds = _tickRate.inMilliseconds / 1000.0;

    _ambientBreath = (sin(t * 0.34) + 1.0) * 0.5;
    _ambientDrift = (sin(t * 0.11) + 1.0) * 0.5;
    _ambientPulse = (sin(t * 1.65) + 1.0) * 0.5;

    _interactionEnergy =
        (_interactionEnergy - (0.42 * deltaSeconds)).clamp(0.0, 1.0);

    _pointerPosition =
        Offset.lerp(_pointerPosition, _pointerTarget, 0.075) ?? _pointerPosition;

    final int seconds = _presence.inSeconds;
    if (seconds < 45) {
      _ambientStage = 0;
    } else if (seconds < 120) {
      _ambientStage = 1;
    } else if (seconds < 240) {
      _ambientStage = 2;
    } else {
      _ambientStage = 3;
    }

    _isIdle = _timeSinceInteraction.inMilliseconds > 3800 &&
        _interactionEnergy < 0.035 &&
        _presence.inSeconds > 5;

    setState(() {});
  }

  void _registerInteraction(Offset pos, {double gain = 0.04}) {
    _timeSinceInteraction = Duration.zero;
    _interactionEnergy = (_interactionEnergy + gain).clamp(0.0, 1.0);
    _pointerTarget = pos;
  }

  void _onPointerHover(PointerHoverEvent event) {
    _isPointerInside = true;
    _registerInteraction(event.localPosition, gain: 0.012);
  }

  void _onPointerMove(PointerMoveEvent event) {
    _isPointerInside = true;
    _registerInteraction(event.localPosition, gain: 0.02);
  }

  void _onPointerDown(PointerDownEvent event) {
    _isPointerInside = true;
    _registerInteraction(event.localPosition, gain: 0.065);
  }

  void _onPointerExit(PointerExitEvent event) {
    _isPointerInside = false;
  }

  @override
  Widget build(BuildContext context) {
    final double presenceSeconds = _presence.inMilliseconds / 1000.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Size size = constraints.biggest;
          final Offset screenCenter = Offset(size.width / 2, size.height / 2);

          if (_pointerPosition == Offset.zero && _pointerTarget == Offset.zero) {
            _pointerPosition = screenCenter;
            _pointerTarget = screenCenter;
          }

          final double logoBaseScale = 1.0 +
              (_ambientStage * 0.008) +
              (_interactionEnergy * 0.028) +
              ((_ambientBreath - 0.5) * 0.018);

          final double logoYOffset =
              ((_ambientDrift - 0.5) * 14.0) - (_interactionEnergy * 3.0);

          final double titleOpacity =
              (0.20 + (_ambientBreath * 0.10) + (_interactionEnergy * 0.06))
                  .clamp(0.0, 1.0);

          final double footerOpacity =
              (0.16 + (_ambientPulse * 0.10) + (_interactionEnergy * 0.05))
                  .clamp(0.0, 1.0);

          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerHover: _onPointerHover,
            onPointerMove: _onPointerMove,
            onPointerDown: _onPointerDown,
            child: MouseRegion(
              onExit: _onPointerExit,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                opacity: _didBoot ? 1.0 : 0.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: Colors.black),

                    ZeronBackground(
                      presenceSeconds: presenceSeconds,
                      ambientStage: _ambientStage,
                      interactionEnergy: _interactionEnergy,
                      pointerPosition: _pointerPosition,
                    ),

                    ZeronDistortion(
                      presenceSeconds: presenceSeconds,
                      ambientStage: _ambientStage,
                      interactionEnergy: _interactionEnergy * 0.58,
                      pointerPosition: _pointerPosition,
                    ),

                    ZeronGlow(
                      presenceSeconds: presenceSeconds,
                      ambientStage: _ambientStage,
                      interactionEnergy: _interactionEnergy,
                      pointerPosition: _pointerPosition,
                      memoryPresence: 0.0,
                      memoryType: 'none',
                    ),

                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.0, -0.04),
                            radius: 1.06,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.24),
                              Colors.black.withValues(alpha: 0.52),
                            ],
                            stops: const [0.0, 0.48, 0.78, 1.0],
                          ),
                        ),
                      ),
                    ),

                    ZeronNoise(
                      presenceSeconds: presenceSeconds,
                      ambientStage: _ambientStage,
                      interactionEnergy: _interactionEnergy,
                      isPointerInside: _isPointerInside,
                    ),

                    Center(
                      child: Transform.translate(
                        offset: Offset(0, logoYOffset),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeOutCubic,
                          scale: logoBaseScale,
                          child: ZeronLogo(isIdle: _isIdle),
                        ),
                      ),
                    ),

                    IgnorePointer(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 22,
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 700),
                                  opacity: titleOpacity,
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      (_ambientBreath - 0.5) * 4.0,
                                    ),
                                    child: const Text(
                                      'ZERON TOKYO',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        letterSpacing: 5.6,
                                        fontWeight: FontWeight.w300,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 700),
                                opacity: footerOpacity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 1,
                                      color: Colors.white.withValues(alpha: 0.18),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'AMBIENT PRESENCE INTERFACE',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        letterSpacing: 3.2,
                                        fontWeight: FontWeight.w300,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _isIdle
                                          ? 'IDLE PRESENCE ACTIVE'
                                          : 'FIELD LISTENING',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.42),
                                        fontSize: 8.5,
                                        letterSpacing: 2.4,
                                        fontWeight: FontWeight.w300,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}