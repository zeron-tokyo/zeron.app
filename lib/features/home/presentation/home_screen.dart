import 'dart:async';
import 'dart:math';

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

class _ZeronHomeScreenState extends State<ZeronHomeScreen> {
  final Random _random = Random();

  final List<String> _messagePool = const [
    'noticed something',
    'it noticed your presence',
    'you stayed here for a while',
    'the space feels different',
    'something is still here',
  ];

  Offset? _pointerPosition;

  Duration _presence = Duration.zero;
  Timer? _presenceTimer;
  Timer? _idleTimer;
  Timer? _messageHideTimer;
  Timer? _ambientShiftTimer;

  bool _isIdle = false;
  String? _currentMessage;

  bool _event20Shown = false;
  bool _event45Shown = false;
  bool _event90Shown = false;

  int _ambientShiftStage = 0;
  Offset _ambientDriftOffset = Offset.zero;
  double _ambientVeilOpacity = 0.0;
  double _ambientBandOpacity = 0.0;
  double _ambientScale = 1.0;

  @override
  void initState() {
    super.initState();
    _startPresenceTimer();
    _startAmbientShiftTimer();
    _resetIdleTimer();
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _idleTimer?.cancel();
    _messageHideTimer?.cancel();
    _ambientShiftTimer?.cancel();
    super.dispose();
  }

  void _startPresenceTimer() {
    _presenceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _presence += const Duration(seconds: 1);
      });

      final seconds = _presence.inSeconds;

      if (seconds >= 20 && !_event20Shown) {
        _event20Shown = true;
        _showPresenceMessage();
      }

      if (seconds >= 45 && !_event45Shown) {
        _event45Shown = true;
        _showPresenceMessage();
      }

      if (seconds >= 90 && !_event90Shown) {
        _event90Shown = true;
        _showPresenceMessage();
      }

      _syncAmbientShiftStage();
    });
  }

  void _startAmbientShiftTimer() {
    _ambientShiftTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      if (_ambientShiftStage == 0) return;
      _applyAmbientShift();
    });
  }

  void _syncAmbientShiftStage() {
    final nextStage = _calculateAmbientShiftStage();

    if (nextStage != _ambientShiftStage) {
      _ambientShiftStage = nextStage;
      _applyAmbientShift();
    }
  }

  int _calculateAmbientShiftStage() {
    final seconds = _presence.inSeconds;

    if (seconds >= 180) return 3;
    if (seconds >= 120) return 2;
    if (seconds >= 60) return 1;
    return 0;
  }

  void _applyAmbientShift() {
    final stage = _ambientShiftStage;

    if (stage == 0) {
      setState(() {
        _ambientDriftOffset = Offset.zero;
        _ambientVeilOpacity = 0.0;
        _ambientBandOpacity = 0.0;
        _ambientScale = 1.0;
      });
      return;
    }

    final maxDrift = switch (stage) {
      1 => 8.0,
      2 => 16.0,
      _ => 24.0,
    };

    final veilBase = switch (stage) {
      1 => 0.035,
      2 => 0.06,
      _ => 0.09,
    };

    final bandBase = switch (stage) {
      1 => 0.03,
      2 => 0.05,
      _ => 0.075,
    };

    final scaleBase = switch (stage) {
      1 => 1.01,
      2 => 1.02,
      _ => 1.035,
    };

    setState(() {
      _ambientDriftOffset = Offset(
        (_random.nextDouble() * 2 - 1) * maxDrift,
        (_random.nextDouble() * 2 - 1) * (maxDrift * 0.5),
      );

      _ambientVeilOpacity = veilBase + (_random.nextDouble() * 0.02);
      _ambientBandOpacity = bandBase + (_random.nextDouble() * 0.02);
      _ambientScale = scaleBase + (_random.nextDouble() * 0.01);
    });
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();

    if (_isIdle) {
      setState(() {
        _isIdle = false;
      });
    }

    _idleTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _isIdle = true;
      });
    });
  }

  void _handlePointerEvent(PointerEvent event) {
    setState(() {
      _pointerPosition = event.localPosition;
    });
    _resetIdleTimer();
  }

  void _showPresenceMessage() {
    _messageHideTimer?.cancel();

    final nextMessage = _pickRandomMessage(exclude: _currentMessage);

    setState(() {
      _currentMessage = nextMessage;
    });

    _messageHideTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _currentMessage = null;
      });
    });
  }

  String _pickRandomMessage({String? exclude}) {
    final candidates =
    _messagePool.where((message) => message != exclude).toList();

    if (candidates.isEmpty) {
      return _messagePool[_random.nextInt(_messagePool.length)];
    }

    return candidates[_random.nextInt(candidates.length)];
  }

  @override
  Widget build(BuildContext context) {
    final bottomGlowOpacity = switch (_ambientShiftStage) {
      1 => 0.05,
      2 => 0.08,
      3 => 0.12,
      _ => 0.03,
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
        onPointerHover: _handlePointerEvent,
        onPointerMove: _handlePointerEvent,
        onPointerDown: _handlePointerEvent,
        child: Stack(
          children: [
            const ZeronDistortion(),
            const ZeronNoise(),
            ZeronBackground(
              pointerPosition: _pointerPosition,
            ),
            IgnorePointer(
              child: AnimatedScale(
                duration: const Duration(seconds: 8),
                curve: Curves.easeInOut,
                scale: _ambientScale,
                child: AnimatedSlide(
                  duration: const Duration(seconds: 8),
                  curve: Curves.easeInOut,
                  offset: Offset(
                    _ambientDriftOffset.dx / 400,
                    _ambientDriftOffset.dy / 400,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 6),
                    opacity: _ambientVeilOpacity,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, -0.1),
                          radius: 0.95,
                          colors: [
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: AnimatedSlide(
                  duration: const Duration(seconds: 8),
                  curve: Curves.easeInOut,
                  offset: Offset(
                    _ambientDriftOffset.dx / 600,
                    _ambientDriftOffset.dy / 700,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 6),
                    opacity: _ambientBandOpacity,
                    child: Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ZeronGlow(
              isIdle: _isIdle,
            ),
            Center(
              child: ZeronLogo(
                isIdle: _isIdle,
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _currentMessage == null ? 0 : (_isIdle ? 0.9 : 0.72),
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, 120),
                    child: Text(
                      _currentMessage ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1200),
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(
                          (_isIdle ? 0.06 : bottomGlowOpacity),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}