enum ZeronPlan {
  free,
  plus,
  sponsor,
}

enum TeamKind {
  friends,
  family,
  company,
}

enum RankScope {
  world,
  country,
  city,
  team,
}

enum AntiCheatFlag {
  none,
  suspiciousSpeed,
  suspiciousDistance,
  deviceMismatch,
  repeatedPattern,
  gpsAnomaly,
}

class ZeronUser {
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
    this.displayName,
    this.avatarUrl,
    this.lastActiveAt,
    this.primaryTeamId,
    this.totalSteps = 0,
    this.totalCo2KgSaved = 0,
    this.totalPrimePoints = 0,
    this.todaySteps = 0,
    this.todayCo2KgSaved = 0,
    this.todayPrimePoints = 0,
    this.worldRank,
    this.countryRank,
    this.cityRank,
    this.teamRank,
    this.antiCheatFlag = AntiCheatFlag.none,
    this.isBanned = false,
    this.isDeleted = false,
  });

  final String id;
  final String email;
  final String countryCode;
  final String countryName;
  final String city;
  final ZeronPlan plan;
  final bool termsAccepted;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? displayName;
  final String? avatarUrl;
  final DateTime? lastActiveAt;
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

  final AntiCheatFlag antiCheatFlag;
  final bool isBanned;
  final bool isDeleted;

  ZeronUser copyWith({
    String? id,
    String? email,
    String? countryCode,
    String? countryName,
    String? city,
    ZeronPlan? plan,
    bool? termsAccepted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? displayName,
    String? avatarUrl,
    DateTime? lastActiveAt,
    String? primaryTeamId,
    int? totalSteps,
    double? totalCo2KgSaved,
    int? totalPrimePoints,
    int? todaySteps,
    double? todayCo2KgSaved,
    int? todayPrimePoints,
    int? worldRank,
    int? countryRank,
    int? cityRank,
    int? teamRank,
    AntiCheatFlag? antiCheatFlag,
    bool? isBanned,
    bool? isDeleted,
  }) {
    return ZeronUser(
      id: id ?? this.id,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      city: city ?? this.city,
      plan: plan ?? this.plan,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      primaryTeamId: primaryTeamId ?? this.primaryTeamId,
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
      antiCheatFlag: antiCheatFlag ?? this.antiCheatFlag,
      isBanned: isBanned ?? this.isBanned,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'countryCode': countryCode,
      'countryName': countryName,
      'city': city,
      'plan': plan.name,
      'termsAccepted': termsAccepted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'primaryTeamId': primaryTeamId,
      'totalSteps': totalSteps,
      'totalCo2KgSaved': totalCo2KgSaved,
      'totalPrimePoints': totalPrimePoints,
      'todaySteps': todaySteps,
      'todayCo2KgSaved': todayCo2KgSaved,
      'todayPrimePoints': todayPrimePoints,
      'worldRank': worldRank,
      'countryRank': countryRank,
      'cityRank': cityRank,
      'teamRank': teamRank,
      'antiCheatFlag': antiCheatFlag.name,
      'isBanned': isBanned,
      'isDeleted': isDeleted,
    };
  }

  factory ZeronUser.fromMap(Map<String, dynamic> map) {
    return ZeronUser(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      countryCode: map['countryCode'] as String? ?? '',
      countryName: map['countryName'] as String? ?? '',
      city: map['city'] as String? ?? '',
      plan: _planFromString(map['plan'] as String?),
      termsAccepted: map['termsAccepted'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      displayName: map['displayName'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      lastActiveAt: map['lastActiveAt'] == null
          ? null
          : DateTime.tryParse(map['lastActiveAt'] as String),
      primaryTeamId: map['primaryTeamId'] as String?,
      totalSteps: (map['totalSteps'] as num?)?.toInt() ?? 0,
      totalCo2KgSaved: (map['totalCo2KgSaved'] as num?)?.toDouble() ?? 0,
      totalPrimePoints: (map['totalPrimePoints'] as num?)?.toInt() ?? 0,
      todaySteps: (map['todaySteps'] as num?)?.toInt() ?? 0,
      todayCo2KgSaved: (map['todayCo2KgSaved'] as num?)?.toDouble() ?? 0,
      todayPrimePoints: (map['todayPrimePoints'] as num?)?.toInt() ?? 0,
      worldRank: (map['worldRank'] as num?)?.toInt(),
      countryRank: (map['countryRank'] as num?)?.toInt(),
      cityRank: (map['cityRank'] as num?)?.toInt(),
      teamRank: (map['teamRank'] as num?)?.toInt(),
      antiCheatFlag: _antiCheatFlagFromString(
        map['antiCheatFlag'] as String?,
      ),
      isBanned: map['isBanned'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }
}

class StepRecord {
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
    this.deviceId,
    this.avgSpeedKmh,
    this.isValidated = false,
    this.antiCheatFlag = AntiCheatFlag.none,
  });

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
  final String? deviceId;
  final double? avgSpeedKmh;
  final bool isValidated;
  final AntiCheatFlag antiCheatFlag;

  StepRecord copyWith({
    String? id,
    String? userId,
    String? dateKey,
    int? stepCount,
    double? distanceKm,
    double? co2KgSaved,
    int? primePoints,
    String? source,
    DateTime? recordedAt,
    DateTime? updatedAt,
    String? deviceId,
    double? avgSpeedKmh,
    bool? isValidated,
    AntiCheatFlag? antiCheatFlag,
  }) {
    return StepRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateKey: dateKey ?? this.dateKey,
      stepCount: stepCount ?? this.stepCount,
      distanceKm: distanceKm ?? this.distanceKm,
      co2KgSaved: co2KgSaved ?? this.co2KgSaved,
      primePoints: primePoints ?? this.primePoints,
      source: source ?? this.source,
      recordedAt: recordedAt ?? this.recordedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      isValidated: isValidated ?? this.isValidated,
      antiCheatFlag: antiCheatFlag ?? this.antiCheatFlag,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'dateKey': dateKey,
      'stepCount': stepCount,
      'distanceKm': distanceKm,
      'co2KgSaved': co2KgSaved,
      'primePoints': primePoints,
      'source': source,
      'recordedAt': recordedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deviceId': deviceId,
      'avgSpeedKmh': avgSpeedKmh,
      'isValidated': isValidated,
      'antiCheatFlag': antiCheatFlag.name,
    };
  }

  factory StepRecord.fromMap(Map<String, dynamic> map) {
    return StepRecord(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      stepCount: (map['stepCount'] as num?)?.toInt() ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      co2KgSaved: (map['co2KgSaved'] as num?)?.toDouble() ?? 0,
      primePoints: (map['primePoints'] as num?)?.toInt() ?? 0,
      source: map['source'] as String? ?? '',
      recordedAt: DateTime.tryParse(map['recordedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      deviceId: map['deviceId'] as String?,
      avgSpeedKmh: (map['avgSpeedKmh'] as num?)?.toDouble(),
      isValidated: map['isValidated'] as bool? ?? false,
      antiCheatFlag: _antiCheatFlagFromString(
        map['antiCheatFlag'] as String?,
      ),
    );
  }
}

class TeamModel {
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
    this.isPrivate = false,
  });

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
  final bool isPrivate;

  TeamModel copyWith({
    String? id,
    String? name,
    TeamKind? kind,
    String? ownerUserId,
    int? memberCount,
    int? totalSteps,
    double? totalCo2KgSaved,
    int? totalPrimePoints,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    String? countryCode,
    String? city,
    bool? isPrivate,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      memberCount: memberCount ?? this.memberCount,
      totalSteps: totalSteps ?? this.totalSteps,
      totalCo2KgSaved: totalCo2KgSaved ?? this.totalCo2KgSaved,
      totalPrimePoints: totalPrimePoints ?? this.totalPrimePoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      countryCode: countryCode ?? this.countryCode,
      city: city ?? this.city,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'kind': kind.name,
      'ownerUserId': ownerUserId,
      'memberCount': memberCount,
      'totalSteps': totalSteps,
      'totalCo2KgSaved': totalCo2KgSaved,
      'totalPrimePoints': totalPrimePoints,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'countryCode': countryCode,
      'city': city,
      'isPrivate': isPrivate,
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      kind: _teamKindFromString(map['kind'] as String?),
      ownerUserId: map['ownerUserId'] as String? ?? '',
      memberCount: (map['memberCount'] as num?)?.toInt() ?? 0,
      totalSteps: (map['totalSteps'] as num?)?.toInt() ?? 0,
      totalCo2KgSaved: (map['totalCo2KgSaved'] as num?)?.toDouble() ?? 0,
      totalPrimePoints: (map['totalPrimePoints'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      description: map['description'] as String?,
      countryCode: map['countryCode'] as String?,
      city: map['city'] as String?,
      isPrivate: map['isPrivate'] as bool? ?? false,
    );
  }
}

class RankEntryModel {
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

  final String id;
  final RankScope scope;
  final int rank;
  final String name;
  final int value;
  final String label;
  final bool isCurrentUser;
  final String? relatedUserId;
  final String? relatedTeamId;

  RankEntryModel copyWith({
    String? id,
    RankScope? scope,
    int? rank,
    String? name,
    int? value,
    String? label,
    bool? isCurrentUser,
    String? relatedUserId,
    String? relatedTeamId,
  }) {
    return RankEntryModel(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      rank: rank ?? this.rank,
      name: name ?? this.name,
      value: value ?? this.value,
      label: label ?? this.label,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      relatedUserId: relatedUserId ?? this.relatedUserId,
      relatedTeamId: relatedTeamId ?? this.relatedTeamId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scope': scope.name,
      'rank': rank,
      'name': name,
      'value': value,
      'label': label,
      'isCurrentUser': isCurrentUser,
      'relatedUserId': relatedUserId,
      'relatedTeamId': relatedTeamId,
    };
  }

  factory RankEntryModel.fromMap(Map<String, dynamic> map) {
    return RankEntryModel(
      id: map['id'] as String? ?? '',
      scope: _rankScopeFromString(map['scope'] as String?),
      rank: (map['rank'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      value: (map['value'] as num?)?.toInt() ?? 0,
      label: map['label'] as String? ?? '',
      isCurrentUser: map['isCurrentUser'] as bool? ?? false,
      relatedUserId: map['relatedUserId'] as String?,
      relatedTeamId: map['relatedTeamId'] as String?,
    );
  }
}

class DailyImpactSummary {
  const DailyImpactSummary({
    required this.dateKey,
    required this.totalSteps,
    required this.totalCo2KgSaved,
    required this.totalPrimePoints,
    required this.goalSteps,
  });

  final String dateKey;
  final int totalSteps;
  final double totalCo2KgSaved;
  final int totalPrimePoints;
  final int goalSteps;

  double get goalProgress {
    if (goalSteps <= 0) return 0;
    return (totalSteps / goalSteps).clamp(0.0, 1.0);
  }

  bool get isGoalCompleted => totalSteps >= goalSteps;

  DailyImpactSummary copyWith({
    String? dateKey,
    int? totalSteps,
    double? totalCo2KgSaved,
    int? totalPrimePoints,
    int? goalSteps,
  }) {
    return DailyImpactSummary(
      dateKey: dateKey ?? this.dateKey,
      totalSteps: totalSteps ?? this.totalSteps,
      totalCo2KgSaved: totalCo2KgSaved ?? this.totalCo2KgSaved,
      totalPrimePoints: totalPrimePoints ?? this.totalPrimePoints,
      goalSteps: goalSteps ?? this.goalSteps,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'totalSteps': totalSteps,
      'totalCo2KgSaved': totalCo2KgSaved,
      'totalPrimePoints': totalPrimePoints,
      'goalSteps': goalSteps,
    };
  }

  factory DailyImpactSummary.fromMap(Map<String, dynamic> map) {
    return DailyImpactSummary(
      dateKey: map['dateKey'] as String? ?? '',
      totalSteps: (map['totalSteps'] as num?)?.toInt() ?? 0,
      totalCo2KgSaved: (map['totalCo2KgSaved'] as num?)?.toDouble() ?? 0,
      totalPrimePoints: (map['totalPrimePoints'] as num?)?.toInt() ?? 0,
      goalSteps: (map['goalSteps'] as num?)?.toInt() ?? 0,
    );
  }
}

class GlobalImpactSnapshot {
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

  GlobalImpactSnapshot copyWith({
    int? activeUsers,
    int? activeTeams,
    int? activeCountries,
    int? activeCities,
    int? totalStepsToday,
    int? totalStepsThisMonth,
    double? totalCo2KgSaved,
    int? totalPrimePoints,
    int? rewardPoolYen,
    DateTime? updatedAt,
  }) {
    return GlobalImpactSnapshot(
      activeUsers: activeUsers ?? this.activeUsers,
      activeTeams: activeTeams ?? this.activeTeams,
      activeCountries: activeCountries ?? this.activeCountries,
      activeCities: activeCities ?? this.activeCities,
      totalStepsToday: totalStepsToday ?? this.totalStepsToday,
      totalStepsThisMonth: totalStepsThisMonth ?? this.totalStepsThisMonth,
      totalCo2KgSaved: totalCo2KgSaved ?? this.totalCo2KgSaved,
      totalPrimePoints: totalPrimePoints ?? this.totalPrimePoints,
      rewardPoolYen: rewardPoolYen ?? this.rewardPoolYen,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activeUsers': activeUsers,
      'activeTeams': activeTeams,
      'activeCountries': activeCountries,
      'activeCities': activeCities,
      'totalStepsToday': totalStepsToday,
      'totalStepsThisMonth': totalStepsThisMonth,
      'totalCo2KgSaved': totalCo2KgSaved,
      'totalPrimePoints': totalPrimePoints,
      'rewardPoolYen': rewardPoolYen,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GlobalImpactSnapshot.fromMap(Map<String, dynamic> map) {
    return GlobalImpactSnapshot(
      activeUsers: (map['activeUsers'] as num?)?.toInt() ?? 0,
      activeTeams: (map['activeTeams'] as num?)?.toInt() ?? 0,
      activeCountries: (map['activeCountries'] as num?)?.toInt() ?? 0,
      activeCities: (map['activeCities'] as num?)?.toInt() ?? 0,
      totalStepsToday: (map['totalStepsToday'] as num?)?.toInt() ?? 0,
      totalStepsThisMonth: (map['totalStepsThisMonth'] as num?)?.toInt() ?? 0,
      totalCo2KgSaved: (map['totalCo2KgSaved'] as num?)?.toDouble() ?? 0,
      totalPrimePoints: (map['totalPrimePoints'] as num?)?.toInt() ?? 0,
      rewardPoolYen: (map['rewardPoolYen'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class ZeronImpactCalculator {
  const ZeronImpactCalculator._();

  static const double stepsPerKm = 1250.0;

  static double calculateDistanceKmFromSteps(int steps) {
    if (steps <= 0) return 0;
    return steps / stepsPerKm;
  }

  static double calculateCo2KgSavedFromSteps(int steps) {
    final distanceKm = calculateDistanceKmFromSteps(steps);
    return calculateCo2KgSavedFromDistance(distanceKm);
  }

  static double calculateCo2KgSavedFromDistance(double distanceKm) {
    if (distanceKm <= 0) return 0;
    const double kgPerKm = 0.12;
    return distanceKm * kgPerKm;
  }

  static int calculatePrimePoints({
    required int steps,
    required double co2KgSaved,
    bool hasDailyGoalBonus = false,
    bool hasEventBoost = false,
  }) {
    if (steps <= 0) return 0;

    final int baseFromSteps = steps ~/ 100;
    final int baseFromCo2 = (co2KgSaved * 100).round();
    int total = baseFromSteps + baseFromCo2;

    if (hasDailyGoalBonus) {
      total += 50;
    }

    if (hasEventBoost) {
      total = (total * 1.2).round();
    }

    return total;
  }

  static DailyImpactSummary buildDailySummary({
    required String dateKey,
    required int totalSteps,
    required int goalSteps,
    bool hasDailyGoalBonus = false,
    bool hasEventBoost = false,
  }) {
    final double co2 = calculateCo2KgSavedFromSteps(totalSteps);
    final int points = calculatePrimePoints(
      steps: totalSteps,
      co2KgSaved: co2,
      hasDailyGoalBonus: hasDailyGoalBonus,
      hasEventBoost: hasEventBoost,
    );

    return DailyImpactSummary(
      dateKey: dateKey,
      totalSteps: totalSteps,
      totalCo2KgSaved: co2,
      totalPrimePoints: points,
      goalSteps: goalSteps,
    );
  }
}

ZeronPlan _planFromString(String? value) {
  return ZeronPlan.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ZeronPlan.free,
  );
}

TeamKind _teamKindFromString(String? value) {
  return TeamKind.values.firstWhere(
    (item) => item.name == value,
    orElse: () => TeamKind.friends,
  );
}

RankScope _rankScopeFromString(String? value) {
  return RankScope.values.firstWhere(
    (item) => item.name == value,
    orElse: () => RankScope.world,
  );
}

AntiCheatFlag _antiCheatFlagFromString(String? value) {
  return AntiCheatFlag.values.firstWhere(
    (item) => item.name == value,
    orElse: () => AntiCheatFlag.none,
  );
}