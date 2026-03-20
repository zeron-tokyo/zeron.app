class UserModel {
  final String id;
  final String email;
  final String country;
  final String city;

  final int stepsToday;
  final int totalSteps;
  final double co2Kg;
  final int points;

  const UserModel({
    required this.id,
    required this.email,
    required this.country,
    required this.city,
    required this.stepsToday,
    required this.totalSteps,
    required this.co2Kg,
    required this.points,
  });
}

class TeamModel {
  final String id;
  final String name;
  final int totalSteps;
  final int members;

  const TeamModel({
    required this.id,
    required this.name,
    required this.totalSteps,
    required this.members,
  });
}

class GlobalStats {
  final int totalSteps;
  final int activeUsers;
  final int co2Saved;

  const GlobalStats({
    required this.totalSteps,
    required this.activeUsers,
    required this.co2Saved,
  });
}