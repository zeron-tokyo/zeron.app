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
  static String? _activeDateKey;

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
    _activeDateKey = _todayKey();

    _subscription = Pedometer.stepCountStream.listen(
      _handleStepEvent,
      onError: (_) {
        _emitSafely(_latestSteps);
      },
      cancelOnError: false,
    );
  }

  static void _handleStepEvent(StepCount event) {
    final nowKey = _todayKey();

    if (_activeDateKey != nowKey) {
      _activeDateKey = nowKey;
      _baseSteps = event.steps;
      _latestSteps = 0;
      _emitSafely(0);
      return;
    }

    _baseSteps ??= event.steps;

    final currentSteps = event.steps - (_baseSteps ?? event.steps);
    _latestSteps = currentSteps < 0 ? 0 : currentSteps;

    _emitSafely(_latestSteps);
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
    final safeSteps = steps < 0 ? 0 : steps;
    final now = DateTime.now();
    final dateKey =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    return ZeronImpactCalculator.buildDailySummary(
      dateKey: dateKey,
      totalSteps: safeSteps,
      goalSteps: 10000,
    );
  }

  /// ===============================
  /// ユーザー反映
  /// today値は現在値に置換
  /// total値は「本日の増分のみ」を加算
  /// ===============================
  static ZeronUser applyToUser({
    required ZeronUser user,
    required int steps,
  }) {
    final summary = buildSummary(steps);

    final previousTodaySteps = user.todaySteps < 0 ? 0 : user.todaySteps;
    final previousTodayCo2 = user.todayCo2KgSaved < 0 ? 0 : user.todayCo2KgSaved;
    final previousTodayPoints = user.todayPrimePoints < 0 ? 0 : user.todayPrimePoints;

    final deltaSteps = (summary.totalSteps - previousTodaySteps).clamp(0, 1 << 30);
    final deltaCo2 = summary.totalCo2KgSaved - previousTodayCo2;
    final deltaPoints =
        (summary.totalPrimePoints - previousTodayPoints).clamp(0, 1 << 30);

    return user.copyWith(
      todaySteps: summary.totalSteps,
      todayCo2KgSaved: summary.totalCo2KgSaved,
      todayPrimePoints: summary.totalPrimePoints,
      totalSteps: user.totalSteps + deltaSteps,
      totalCo2KgSaved: user.totalCo2KgSaved + (deltaCo2 < 0 ? 0 : deltaCo2),
      totalPrimePoints: user.totalPrimePoints + deltaPoints,
      updatedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
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
    _activeDateKey = null;
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
    _activeDateKey = null;
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

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }
}