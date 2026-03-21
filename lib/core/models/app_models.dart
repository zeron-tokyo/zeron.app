import 'dart:math';

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
      worldRank: worldRank,
      countryRank: countryRank,
      cityRank: cityRank,
      teamRank: teamRank,
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

  final double totalCo2KgSaved;
  final int totalPrimePoints;

  final bool hasDailyGoalBonus;

  /// UI用
  double get goalProgress =>
      goalSteps == 0 ? 0 : (totalSteps / goalSteps).clamp(0.0, 1.0);

  const DailyImpactSummary({
    required this.dateKey,
    required this.totalSteps,
    required this.goalSteps,
    required this.totalCo2KgSaved,
    required this.totalPrimePoints,
    required this.hasDailyGoalBonus,
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
/// IMPACT CALCULATOR（中核）
/// ===============================

class ZeronImpactCalculator {
  static const double _stepLengthKm = 0.00075;
  static const double _co2PerKm = 0.12;

  static double calculateDistanceKmFromSteps(int steps) {
    return steps * _stepLengthKm;
  }

  static double calculateCo2KgSavedFromSteps(int steps) {
    final distance = calculateDistanceKmFromSteps(steps);
    return calculateCo2KgSavedFromDistance(distance);
  }

  static double calculateCo2KgSavedFromDistance(double distanceKm) {
    return distanceKm * _co2PerKm;
  }

  static int calculatePrimePoints({
    required int steps,
    required double co2KgSaved,
    required bool hasDailyGoalBonus,
  }) {
    final base = (steps * 0.01).floor();
    final co2Bonus = (co2KgSaved * 10).floor();
    final goalBonus = hasDailyGoalBonus ? 100 : 0;

    return base + co2Bonus + goalBonus;
  }

  static DailyImpactSummary buildDailySummary({
    required String dateKey,
    required int totalSteps,
    required int goalSteps,
    required bool hasDailyGoalBonus,
  }) {
    final co2 = calculateCo2KgSavedFromSteps(totalSteps);

    final points = calculatePrimePoints(
      steps: totalSteps,
      co2KgSaved: co2,
      hasDailyGoalBonus: hasDailyGoalBonus,
    );

    return DailyImpactSummary(
      dateKey: dateKey,
      totalSteps: totalSteps,
      goalSteps: goalSteps,
      totalCo2KgSaved: co2,
      totalPrimePoints: points,
      hasDailyGoalBonus: hasDailyGoalBonus,
    );
  }
}