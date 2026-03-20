import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeron/core/models/app_models.dart';

class StepService {
  const StepService._();

  static StreamSubscription<StepCount>? _subscription;

  static final StreamController<int> _stepController =
      StreamController<int>.broadcast();

  static int _baseSteps = 0;

  /// ===============================
  /// 初期化（最重要）
  /// ===============================
  static Future<void> init() async {
    final permission = await Permission.activityRecognition.request();

    if (!permission.isGranted) return;

    final stream = Pedometer.stepCountStream;

    _subscription = stream.listen(
      (StepCount event) {
        if (_baseSteps == 0) {
          _baseSteps = event.steps;
        }

        final currentSteps = event.steps - _baseSteps;

        _stepController.add(currentSteps);
      },
      onError: (error) {},
    );
  }

  /// ===============================
  /// 歩数ストリーム
  /// ===============================
  static Stream<int> get stepStream => _stepController.stream;

  /// ===============================
  /// 今日のSummary生成
  /// ===============================
  static DailyImpactSummary buildSummary(int steps) {
    final now = DateTime.now();

    final dateKey =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    return ZeronImpactCalculator.buildDailySummary(
      dateKey: dateKey,
      totalSteps: steps,
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
      totalCo2KgSaved:
          user.totalCo2KgSaved + summary.totalCo2KgSaved,
      totalPrimePoints:
          user.totalPrimePoints + summary.totalPrimePoints,
      updatedAt: DateTime.now(),
    );
  }

  /// ===============================
  /// dispose
  /// ===============================
  static void dispose() {
    _subscription?.cancel();
    _stepController.close();
  }
}