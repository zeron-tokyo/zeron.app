import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeron/core/models/app_models.dart';

class StepService {
  const StepService._();

  static StreamSubscription<StepCount>? _subscription;
  static StreamController<int> _stepController =
      StreamController<int>.broadcast();

  static bool _isInitialized = false;
  static int? _baseSteps;
  static int _latestSteps = 0;

  /// ===============================
  /// 初期化
  /// ===============================
  static Future<void> init() async {
    if (_isInitialized) return;

    if (_stepController.isClosed) {
      _stepController = StreamController<int>.broadcast();
    }

    final permission = await Permission.activityRecognition.request();

    if (!permission.isGranted) {
      _emitSafely(0);
      return;
    }

    _isInitialized = true;

    _subscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        _baseSteps ??= event.steps;

        final currentSteps = event.steps - (_baseSteps ?? event.steps);
        _latestSteps = currentSteps < 0 ? 0 : currentSteps;

        _emitSafely(_latestSteps);
      },
      onError: (_) {
        _emitSafely(_latestSteps);
      },
      cancelOnError: false,
    );
  }

  /// ===============================
  /// 歩数ストリーム
  /// ===============================
  static Stream<int> get stepStream => _stepController.stream;

  /// ===============================
  /// 現在歩数
  /// ===============================
  static int get currentSteps => _latestSteps;

  /// ===============================
  /// 今日のSummary生成
  /// ===============================
  static DailyImpactSummary buildSummary(int steps) {
    final now = DateTime.now();
    final dateKey =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    return ZeronImpactCalculator.buildDailySummary(
      dateKey: dateKey,
      totalSteps: steps < 0 ? 0 : steps,
      goalSteps: 10000,
      hasDailyGoalBonus: steps >= 10000,
    );
  }

  /// ===============================
  /// ユーザー反映
  /// ===============================
  static ZeronUser applyToUser({
    required ZeronUser user,
    required int steps,
  }) {
    final summary = buildSummary(steps);

    return user.copyWith(
      todaySteps: summary.totalSteps,
      todayCo2KgSaved: summary.totalCo2KgSaved,
      todayPrimePoints: summary.totalPrimePoints,
      totalSteps: user.totalSteps + summary.totalSteps,
      totalCo2KgSaved: user.totalCo2KgSaved + summary.totalCo2KgSaved,
      totalPrimePoints: user.totalPrimePoints + summary.totalPrimePoints,
      lastActiveAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// ===============================
  /// リセット
  /// ===============================
  static Future<void> reset() async {
    await _subscription?.cancel();
    _subscription = null;
    _baseSteps = null;
    _latestSteps = 0;
    _isInitialized = false;
    _emitSafely(0);
  }

  /// ===============================
  /// dispose
  /// ===============================
  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _baseSteps = null;
    _latestSteps = 0;
    _isInitialized = false;

    if (!_stepController.isClosed) {
      await _stepController.close();
    }
  }

  static void _emitSafely(int value) {
    if (!_stepController.isClosed) {
      _stepController.add(value);
    }
  }
}