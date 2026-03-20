import 'dart:math';

import 'package:zeron/core/models/app_models.dart';

class StepService {
  const StepService._();

  static final Random _random = Random();

  /// ===============================
  /// 仮歩数生成（リアル挙動）
  /// ===============================
  static int generateTodaySteps() {
    final hour = DateTime.now().hour;

    int base;

    if (hour < 6) {
      base = _random.nextInt(300); // 深夜
    } else if (hour < 10) {
      base = 500 + _random.nextInt(1500); // 朝
    } else if (hour < 15) {
      base = 2000 + _random.nextInt(4000); // 昼
    } else if (hour < 20) {
      base = 4000 + _random.nextInt(6000); // 夕方ピーク
    } else {
      base = 5000 + _random.nextInt(8000); // 夜
    }

    return base;
  }

  /// ===============================
  /// 日付キー生成
  /// ===============================
  static String generateDateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}"
        "${date.month.toString().padLeft(2, '0')}"
        "${date.day.toString().padLeft(2, '0')}";
  }

  /// ===============================
  /// StepRecord生成
  /// ===============================
  static StepRecord buildStepRecord({
    required String userId,
    required int steps,
    String source = "simulated",
  }) {
    final now = DateTime.now();
    final dateKey = generateDateKey(now);

    final distance =
        ZeronImpactCalculator.calculateDistanceKmFromSteps(steps);

    final co2 =
        ZeronImpactCalculator.calculateCo2KgSavedFromDistance(distance);

    final isGoal = steps >= 8000;

    final points = ZeronImpactCalculator.calculatePrimePoints(
      steps: steps,
      co2KgSaved: co2,
      hasDailyGoalBonus: isGoal,
    );

    return StepRecord(
      id: _generateId(),
      userId: userId,
      dateKey: dateKey,
      stepCount: steps,
      distanceKm: distance,
      co2KgSaved: co2,
      primePoints: points,
      source: source,
      recordedAt: now,
      updatedAt: now,
      avgSpeedKmh: _estimateSpeed(steps),
      isValidated: true,
    );
  }

  /// ===============================
  /// DailySummary生成
  /// ===============================
  static DailyImpactSummary buildTodaySummary({
    required int steps,
    int goalSteps = 8000,
  }) {
    final dateKey = generateDateKey(DateTime.now());

    return ZeronImpactCalculator.buildDailySummary(
      dateKey: dateKey,
      totalSteps: steps,
      goalSteps: goalSteps,
      hasDailyGoalBonus: steps >= goalSteps,
    );
  }

  /// ===============================
  /// ユーザー更新（最重要）
  /// ===============================
  static ZeronUser applyTodayUpdate({
    required ZeronUser user,
    required int todaySteps,
  }) {
    final co2 =
        ZeronImpactCalculator.calculateCo2KgSavedFromSteps(todaySteps);

    final isGoal = todaySteps >= 8000;

    final points = ZeronImpactCalculator.calculatePrimePoints(
      steps: todaySteps,
      co2KgSaved: co2,
      hasDailyGoalBonus: isGoal,
    );

    return user.copyWith(
      todaySteps: todaySteps,
      todayCo2KgSaved: co2,
      todayPrimePoints: points,
      totalSteps: user.totalSteps + todaySteps,
      totalCo2KgSaved: user.totalCo2KgSaved + co2,
      totalPrimePoints: user.totalPrimePoints + points,
      lastActiveAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// ===============================
  /// 過去データ生成（グラフ用）
  /// ===============================
  static List<DailyImpactSummary> generatePastSummaries({
    required int days,
    int goalSteps = 8000,
  }) {
    final List<DailyImpactSummary> list = [];

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final steps = _random.nextInt(12000);

      final summary = ZeronImpactCalculator.buildDailySummary(
        dateKey: generateDateKey(date),
        totalSteps: steps,
        goalSteps: goalSteps,
        hasDailyGoalBonus: steps >= goalSteps,
      );

      list.add(summary);
    }

    return list;
  }

  /// ===============================
  /// 内部：速度推定
  /// ===============================
  static double _estimateSpeed(int steps) {
    if (steps <= 0) return 0;

    final distance =
        ZeronImpactCalculator.calculateDistanceKmFromSteps(steps);

    final hours = max(0.5, _random.nextDouble() * 2.5);

    return distance / hours;
  }

  /// ===============================
  /// 内部：ID生成
  /// ===============================
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(9999).toString();
  }
}