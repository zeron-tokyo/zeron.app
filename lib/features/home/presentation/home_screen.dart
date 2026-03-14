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
  static const Duration _tickRate = Duration(milliseconds: 100);

  final Random _random = Random();

  Timer? _ticker;
  Duration _presence = Duration.zero;

  int _ambientStage = 0;
  int _interactionCount = 0;

  double _interactionEnergy = 0.0;
  double _peakInteractionEnergy = 0.0;

  bool _isPointerInside = false;
  bool _isIdle = false;

  Offset _pointerPosition = Offset.zero;
  Offset _pointerTarget = Offset.zero;

  String? _presenceMessage;
  DateTime? _presenceMessageUntil;

  String? _ambientEventMessage;
  DateTime? _ambientEventUntil;
  Duration? _nextAmbientEventAt;

  bool _hasShown20s = false;
  bool _hasShown45s = false;
  bool _hasShown90s = false;
  bool _hasShown150s = false;

  @override
  void initState() {
    super.initState();
    _scheduleNextAmbientEvent();
    _ticker = Timer.periodic(_tickRate, _onTick);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onTick(Timer timer) {
    if (!mounted) return;

    final double deltaSeconds = _tickRate.inMilliseconds / 1000.0;

    _presence += _tickRate;

    final double nextEnergy = (_interactionEnergy - (0.015 * deltaSeconds))
        .clamp(0.0, 1.0);
    _interactionEnergy = nextEnergy;

    _pointerPosition = Offset.lerp(_pointerPosition, _pointerTarget, 0.08) ??
        _pointerPosition;

    _updateAmbientStage();
    _handlePresenceMilestones();
    _handleAmbientEvent();

    final bool shouldIdle = _interactionEnergy < 0.02 && _presence.inSeconds > 6;
    _isIdle = shouldIdle;

    if (_presenceMessageUntil != null &&
        DateTime.now().isAfter(_presenceMessageUntil!)) {
      _presenceMessage = null;
      _presenceMessageUntil = null;
    }

    if (_ambientEventUntil != null &&
        DateTime.now().isAfter(_ambientEventUntil!)) {
      _ambientEventMessage = null;
      _ambientEventUntil = null;
    }

    setState(() {});
  }

  void _updateAmbientStage() {
    final int seconds = _presence.inSeconds;

    if (seconds >= 180) {
      _ambientStage = 3;
    } else if (seconds >= 120) {
      _ambientStage = 2;
    } else if (seconds >= 60) {
      _ambientStage = 1;
    } else {
      _ambientStage = 0;
    }
  }

  void _handlePresenceMilestones() {
    final int seconds = _presence.inSeconds;

    if (!_hasShown20s && seconds >= 20) {
      _hasShown20s = true;
      _showPresenceMessage('it noticed you');
      return;
    }

    if (!_hasShown45s && seconds >= 45) {
      _hasShown45s = true;
      _showPresenceMessage('you have been here for a while');
      return;
    }

    if (!_hasShown90s && seconds >= 90) {
      _hasShown90s = true;
      _showPresenceMessage(
        _interactionCount >= 12 ? 'it reacts when you move' : 'it waits with you',
      );
      return;
    }

    if (!_hasShown150s && seconds >= 150) {
      _hasShown150s = true;
      _showPresenceMessage(_buildMemoryReactionMessage());
      return;
    }
  }

  String _buildMemoryReactionMessage() {
    final bool activeReaction =
        _interactionCount >= 18 || _peakInteractionEnergy >= 0.35;

    if (activeReaction) {
      return 'it remembers how you touched the room';
    }

    return 'it remembers how still you were';
  }

  void _handleAmbientEvent() {
    if (_nextAmbientEventAt == null) return;
    if (_presence < const Duration(seconds: 24)) return;

    if (_presence >= _nextAmbientEventAt!) {
      final List<String> events = <String>[
        'did it move?',
        'you felt that too',
        'something shifted',
        'the room leaned closer',
      ];

      _ambientEventMessage = events[_random.nextInt(events.length)];
      _ambientEventUntil = DateTime.now().add(
        Duration(milliseconds: 1800 + _random.nextInt(1000)),
      );

      _scheduleNextAmbientEvent();
    }
  }

  void _scheduleNextAmbientEvent() {
    final int gapSeconds = 14 + _random.nextInt(11);
    _nextAmbientEventAt = _presence + Duration(seconds: gapSeconds);
  }

  void _showPresenceMessage(String message) {
    _presenceMessage = message;
    _presenceMessageUntil = DateTime.now().add(const Duration(milliseconds: 3200));
  }

  void _registerInteraction(Offset localPosition, {double gain = 0.04}) {
    _interactionCount += 1;
    _interactionEnergy = (_interactionEnergy + gain).clamp(0.0, 1.0);
    _peakInteractionEnergy = max(_peakInteractionEnergy, _interactionEnergy);
    _pointerTarget = localPosition;
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
    _registerInteraction(event.localPosition, gain: 0.06);
  }

  void _onPointerEnter(PointerEnterEvent event) {
    _isPointerInside = true;
    _pointerTarget = event.localPosition;
  }

  void _onPointerExit(PointerExitEvent event) {
    _isPointerInside = false;
  }

  String? get _overlayMessage {
    if (_ambientEventMessage != null) return _ambientEventMessage;
    if (_presenceMessage != null) return _presenceMessage;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String? overlayMessage = _overlayMessage;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerHover: _onPointerHover,
        onPointerMove: _onPointerMove,
        onPointerDown: _onPointerDown,
        child: MouseRegion(
          onEnter: _onPointerEnter,
          onExit: _onPointerExit,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ZeronDistortion(
                presenceSeconds: _presence.inMilliseconds / 1000.0,
                ambientStage: _ambientStage,
                interactionEnergy: _interactionEnergy,
                pointerPosition: _pointerPosition,
              ),
              ZeronNoise(
                presenceSeconds: _presence.inMilliseconds / 1000.0,
                ambientStage: _ambientStage,
                interactionEnergy: _interactionEnergy,
                isPointerInside: _isPointerInside,
              ),
              ZeronBackground(
                presenceSeconds: _presence.inMilliseconds / 1000.0,
                ambientStage: _ambientStage,
                interactionEnergy: _interactionEnergy,
                pointerPosition: _pointerPosition,
              ),
              ZeronGlow(
                presenceSeconds: _presence.inMilliseconds / 1000.0,
                ambientStage: _ambientStage,
                interactionEnergy: _interactionEnergy,
                pointerPosition: _pointerPosition,
              ),
              Center(
                child: IgnorePointer(
                  child: AnimatedScale(
                    scale: 1.0 + (_ambientStage * 0.008) + (_interactionEnergy * 0.02),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    child: const ZeronLogo(),
                  ),
                ),
              ),
              if (overlayMessage != null)
                _PresenceMessage(
                  message: overlayMessage,
                  stage: _ambientStage,
                  interactionEnergy: _interactionEnergy,
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _BottomGradient(
                  stage: _ambientStage,
                  interactionEnergy: _interactionEnergy,
                  presenceSeconds: _presence.inMilliseconds / 1000.0,
                  isIdle: _isIdle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresenceMessage extends StatelessWidget {
  const _PresenceMessage({
    required this.message,
    required this.stage,
    required this.interactionEnergy,
  });

  final String message;
  final int stage;
  final double interactionEnergy;

  @override
  Widget build(BuildContext context) {
    final double topOffset = 116 + (stage * 10);
    final double opacity = (0.66 + (interactionEnergy * 0.22)).clamp(0.0, 1.0);

    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: topOffset),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.92, end: 1.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double scale, Widget? child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient({
    required this.stage,
    required this.interactionEnergy,
    required this.presenceSeconds,
    required this.isIdle,
  });

  final int stage;
  final double interactionEnergy;
  final double presenceSeconds;
  final bool isIdle;

  @override
  Widget build(BuildContext context) {
    final double intensity = (0.14 +
        (stage * 0.07) +
        (interactionEnergy * 0.28) +
        (isIdle ? 0.04 : 0.0))
        .clamp(0.0, 0.6);

    final double height = 220 + (stage * 30) + (interactionEnergy * 80);

    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              Colors.white.withValues(alpha: intensity * 0.42),
              Colors.white.withValues(alpha: intensity * 0.14),
              Colors.transparent,
            ],
            stops: <double>[
              0.0,
              0.42 + (sin(presenceSeconds * 0.2) * 0.04),
              1.0,
            ],
          ),
        ),
      ),
    );
  }
}