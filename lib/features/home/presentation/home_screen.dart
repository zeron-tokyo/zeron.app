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

  bool _isIdle = false;
  String? _currentMessage;

  bool _event20Shown = false;
  bool _event45Shown = false;
  bool _event90Shown = false;

  @override
  void initState() {
    super.initState();
    _startPresenceTimer();
    _resetIdleTimer();
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _idleTimer?.cancel();
    _messageHideTimer?.cancel();
    super.dispose();
  }

  void _startPresenceTimer() {
    _presenceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
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
                        Colors.white.withOpacity(_isIdle ? 0.06 : 0.03),
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