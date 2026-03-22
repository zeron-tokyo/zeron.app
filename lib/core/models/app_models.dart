/// ===============================
/// ENUM
/// ===============================

enum ZeronPlan { free, plus, sponsor }

enum TeamKind { friends, family, company }

enum RankScope { world, country, city, team }

/// ===============================
/// USER
/// ===============================

class ZeronUser {
  final String id;
  final String email;
  final String countryCode;
  final String countryName;
  final String city;

  final ZeronPlan plan;
  final bool termsAccepted;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;

  final String? displayName;
  final String? primaryTeamId;

  final int totalSteps;
  final double totalCo2KgSaved;
  final int totalPrimePoints;

  final int todaySteps;
  final double todayCo2KgSaved;
  final int todayPrimePoints;

  final int? worldRank;
  final int? countryRank;
  final int? cityRank;
  final int? teamRank;

  const ZeronUser({
    required this.id,
    required this.email,
    required this.countryCode,
    required this.countryName,
    required this.city,
    required this.plan,
    required this.termsAccepted,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
    this.displayName,
    this.primaryTeamId,
    required this.totalSteps,
    required this.totalCo2KgSaved,
    required this.totalPrimePoints,
    required this.todaySteps,
    required this.todayCo2KgSaved,
    required this.todayPrimePoints,
    this.worldRank,
    this.countryRank,
    this.cityRank,
    this.teamRank,
  });

  ZeronUser copyWith({
    int? todaySteps,
    double? todayCo2KgSaved,
    int? todayPrimePoints,
    int? totalSteps,
    double? totalCo2KgSaved,
    int? totalPrimePoints,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    int? worldRank,
    int? countryRank,
    int? cityRank,
    int? teamRank,
  }) {
    return ZeronUser(
      id: id,
      email: email,
      countryCode: countryCode,
      countryName: countryName,
      city: city,
      plan: plan,
      termsAccepted: termsAccepted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      displayName: displayName,
      primaryTeamId: primaryTeamId,
      totalSteps: totalSteps ?? this.totalSteps,
      totalCo2KgSaved: totalCo2KgSaved ?? this.totalCo2KgSaved,
      totalPrimePoints: totalPrimePoints ?? this.totalPrimePoints,
      todaySteps: todaySteps ?? this.todaySteps,
      todayCo2KgSaved: todayCo2KgSaved ?? this.todayCo2KgSaved,
      todayPrimePoints: todayPrimePoints ?? this.todayPrimePoints,
      worldRank: worldRank ?? this.worldRank,
      countryRank: countryRank ?? this.countryRank,
      cityRank: cityRank ?? this.cityRank,
      teamRank: teamRank ?? this.teamRank,
    );
  }
}

/// ===============================
/// STEP RECORD
/// ===============================

class StepRecord {
  final String id;
  final String userId;
  final String dateKey;

  final int stepCount;
  final double distanceKm;
  final double co2KgSaved;
  final int primePoints;

  final String source;

  final DateTime recordedAt;
  final DateTime updatedAt;

  final double avgSpeedKmh;
  final bool isValidated;

  const StepRecord({
    required this.id,
    required this.userId,
    required this.dateKey,
    required this.stepCount,
    required this.distanceKm,
    required this.co2KgSaved,
    required this.primePoints,
    required this.source,
    required this.recordedAt,
    required this.updatedAt,
    required this.avgSpeedKmh,
    required this.isValidated,
  });
}

/// ===============================
/// DAILY SUMMARY
/// ===============================

class DailyImpactSummary {
  final String dateKey;
  final int totalSteps;
  final int goalSteps;

  final double totalDistanceKm;
  final double totalCo2KgSaved;
  final int totalPrimePoints;

  final bool hasDailyGoalBonus;
  final bool reachedMilestone5000;
  final bool reachedMilestone10000;
  final bool reachedMilestone15000;

  double get goalProgress =>
      goalSteps == 0 ? 0 : (totalSteps / goalSteps).clamp(0.0, 1.0);

  int get remainingToGoal => goalSteps > totalSteps ? goalSteps - totalSteps : 0;

  const DailyImpactSummary({
    required this.dateKey,
    required this.totalSteps,
    required this.goalSteps,
    required this.totalDistanceKm,
    required this.totalCo2KgSaved,
    required this.totalPrimePoints,
    required this.hasDailyGoalBonus,
    required this.reachedMilestone5000,
    required this.reachedMilestone10000,
    required this.reachedMilestone15000,
  });
}

/// ===============================
/// TEAM
/// ===============================

class TeamModel {
  final String id;
  final String name;
  final TeamKind kind;
  final String ownerUserId;

  final int memberCount;
  final int totalSteps;
  final double totalCo2KgSaved;
  final int totalPrimePoints;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String? description;
  final String? countryCode;
  final String? city;

  const TeamModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.ownerUserId,
    required this.memberCount,
    required this.totalSteps,
    required this.totalCo2KgSaved,
    required this.totalPrimePoints,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.countryCode,
    this.city,
  });
}

/// ===============================
/// GLOBAL SNAPSHOT
/// ===============================

class GlobalImpactSnapshot {
  final int activeUsers;
  final int activeTeams;
  final int activeCountries;
  final int activeCities;

  final int totalStepsToday;
  final int totalStepsThisMonth;

  final double totalCo2KgSaved;
  final int totalPrimePoints;

  final int rewardPoolYen;

  final DateTime updatedAt;

  const GlobalImpactSnapshot({
    required this.activeUsers,
    required this.activeTeams,
    required this.activeCountries,
    required this.activeCities,
    required this.totalStepsToday,
    required this.totalStepsThisMonth,
    required this.totalCo2KgSaved,
    required this.totalPrimePoints,
    required this.rewardPoolYen,
    required this.updatedAt,
  });
}

/// ===============================
/// RANK
/// ===============================

class RankEntryModel {
  final String id;
  final RankScope scope;
  final int rank;

  final String name;
  final int value;
  final String label;

  final bool isCurrentUser;

  final String? relatedUserId;
  final String? relatedTeamId;

  const RankEntryModel({
    required this.id,
    required this.scope,
    required this.rank,
    required this.name,
    required this.value,
    required this.label,
    this.isCurrentUser = false,
    this.relatedUserId,
    this.relatedTeamId,
  });
}

/// ===============================
/// IMPACT CALCULATOR
/// ===============================

class ZeronImpactCalculator {
  const ZeronImpactCalculator._();

  /// 1歩あたりの平均移動距離
  static const double _stepLengthKm = 0.00075;

  /// 1km歩行で置換される想定CO2削減量
  static const double _co2PerKm = 0.12;

  /// 100歩あたりの基本ポイント
  static const int _basePointsPer100Steps = 1;

  /// 1kgのCO2削減あたりのボーナスポイント
  static const int _pointsPerKgCo2 = 10;

  /// マイルストーンボーナス
  static const int _milestone5000Bonus = 20;
  static const int _milestone10000Bonus = 60;
  static const int _milestone15000Bonus = 120;

  static double calculateDistanceKmFromSteps(int steps) {
    final safeSteps = steps < 0 ? 0 : steps;
    return safeSteps * _stepLengthKm;
  }

  static double calculateCo2KgSavedFromSteps(int steps) {
    final distance = calculateDistanceKmFromSteps(steps);
    return calculateCo2KgSavedFromDistance(distance);
  }

  static double calculateCo2KgSavedFromDistance(double distanceKm) {
    final safeDistance = distanceKm < 0 ? 0.0 : distanceKm;
    return safeDistance * _co2PerKm;
  }

  static int calculatePrimePoints({
    required int steps,
    required double co2KgSaved,
    required bool hasDailyGoalBonus,
  }) {
    final safeSteps = steps < 0 ? 0 : steps;
    final safeCo2 = co2KgSaved < 0 ? 0.0 : co2KgSaved;

    final base = (safeSteps ~/ 100) * _basePointsPer100Steps;
    final co2Bonus = (safeCo2 * _pointsPerKgCo2).floor();

    final milestoneBonus = calculateMilestoneBonus(safeSteps);
    final goalBonus = hasDailyGoalBonus ? 100 : 0;

    return base + co2Bonus + milestoneBonus + goalBonus;
  }

  static int calculateMilestoneBonus(int steps) {
    final safeSteps = steps < 0 ? 0 : steps;
    int bonus = 0;

    if (safeSteps >= 5000) {
      bonus += _milestone5000Bonus;
    }
    if (safeSteps >= 10000) {
      bonus += _milestone10000Bonus;
    }
    if (safeSteps >= 15000) {
      bonus += _milestone15000Bonus;
    }

    return bonus;
  }

  static DailyImpactSummary buildDailySummary({
    required String dateKey,
    required int totalSteps,
    required int goalSteps,
  }) {
    final safeSteps = totalSteps < 0 ? 0 : totalSteps;
    final safeGoal = goalSteps <= 0 ? 10000 : goalSteps;

    final distanceKm = calculateDistanceKmFromSteps(safeSteps);
    final co2 = calculateCo2KgSavedFromDistance(distanceKm);
    final hasGoalBonus = safeSteps >= safeGoal;

    final points = calculatePrimePoints(
      steps: safeSteps,
      co2KgSaved: co2,
      hasDailyGoalBonus: hasGoalBonus,
    );

    return DailyImpactSummary(
      dateKey: dateKey,
      totalSteps: safeSteps,
      goalSteps: safeGoal,
      totalDistanceKm: distanceKm,
      totalCo2KgSaved: co2,
      totalPrimePoints: points,
      hasDailyGoalBonus: hasGoalBonus,
      reachedMilestone5000: safeSteps >= 5000,
      reachedMilestone10000: safeSteps >= 10000,
      reachedMilestone15000: safeSteps >= 15000,
    );
  }
}