import 'package:flutter/material.dart';
import 'package:zeron/core/models/app_models.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  static const Color _panel = Color(0xFF091015);
  static const Color _panelStrong = Color(0xFF0E181A);
  static const Color _border = Color(0x14FFFFFF);
  static const Color _mint = Color(0xFFB8FFE3);
  static const Color _mintStrong = Color(0xFF79F7D4);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xB3FFFFFF);

  String _formatNumber(int value) {
    final source = value.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < source.length; i++) {
      final position = source.length - i;
      buffer.write(source[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write(',');
      }
    }
    final result = buffer.toString();
    return value < 0 ? '-$result' : result;
  }

  @override
  Widget build(BuildContext context) {
    final teams = <TeamModel>[
      TeamModel(
        id: 'team_friends',
        name: 'Friends Team',
        kind: TeamKind.friends,
        ownerUserId: 'user_cocoro_demo',
        memberCount: 12,
        totalSteps: 53000,
        totalCo2KgSaved: 34.8,
        totalPrimePoints: 4820,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description:
            'Turn casual walks into a shared challenge and keep motivation high with weekly movement goals.',
        countryCode: 'JP',
        city: 'Tokyo',
      ),
      TeamModel(
        id: 'team_family',
        name: 'Family Team',
        kind: TeamKind.family,
        ownerUserId: 'user_cocoro_demo',
        memberCount: 5,
        totalSteps: 47500,
        totalCo2KgSaved: 12.6,
        totalPrimePoints: 1940,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description:
            'Make daily health routines visible across your family and grow climate participation together.',
        countryCode: 'JP',
        city: 'Tokyo',
      ),
      TeamModel(
        id: 'team_company',
        name: 'Company Team',
        kind: TeamKind.company,
        ownerUserId: 'user_cocoro_demo',
        memberCount: 48,
        totalSteps: 382000,
        totalCo2KgSaved: 128.4,
        totalPrimePoints: 16300,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description:
            'Scale workplace engagement and show how organizational movement can contribute to global impact.',
        countryCode: 'JP',
        city: 'Tokyo',
      ),
    ];

    final totalMembers = teams.fold<int>(0, (sum, team) => sum + team.memberCount);
    final activeTeams = teams.length;

    final topStepsTeam = [...teams]..sort((a, b) => b.totalSteps.compareTo(a.totalSteps));
    final topImpactTeam = [...teams]
      ..sort((a, b) => b.totalCo2KgSaved.compareTo(a.totalCo2KgSaved));
    final consistencyTeam = [...teams]
      ..sort((a, b) => a.memberCount.compareTo(b.memberCount));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        const _PageHeader(
          title: 'Team',
          subtitle:
              'Build shared momentum with friends, family, and companies through collective walking impact.',
        ),
        const SizedBox(height: 18),
        _TeamHeroCard(
          activeTeams: '$activeTeams',
          combinedMembers: _formatNumber(totalMembers),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          teams.length,
          (index) {
            final team = teams[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == teams.length - 1 ? 0 : 16),
              child: _TeamCard(
                title: team.name,
                subtitle: team.description ?? '',
                icon: _kindIcon(team.kind),
                members: '${_formatNumber(team.memberCount)} members',
                co2Saved: '${team.totalCo2KgSaved.toStringAsFixed(1)} kg CO₂',
                points: '${_formatNumber(team.totalPrimePoints)} Prime Points',
                steps: '${_formatNumber(team.totalSteps)} steps',
                accent: _kindAccent(team.kind),
                badge: _kindBadge(team.kind),
                kindLabel: _kindLabel(team.kind),
                isPrimary: team.kind == TeamKind.company,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _TeamInsightCard(
          mostActiveGroup: topStepsTeam.first.name,
          highestImpactUnit: topImpactTeam.first.name,
          bestConsistencySignal: consistencyTeam.first.name,
        ),
        const SizedBox(height: 16),
        const _CreateTeamCard(),
        const SizedBox(height: 16),
        const _ComingSoonCard(),
      ],
    );
  }

  static IconData _kindIcon(TeamKind kind) {
    switch (kind) {
      case TeamKind.friends:
        return Icons.diversity_3_rounded;
      case TeamKind.family:
        return Icons.favorite_rounded;
      case TeamKind.company:
        return Icons.apartment_rounded;
    }
  }

  static Color _kindAccent(TeamKind kind) {
    switch (kind) {
      case TeamKind.friends:
        return const Color(0xFF79F7D4);
      case TeamKind.family:
        return const Color(0xFF8CD8FF);
      case TeamKind.company:
        return const Color(0xFFFFC978);
    }
  }

  static String _kindLabel(TeamKind kind) {
    switch (kind) {
      case TeamKind.friends:
        return 'Friends';
      case TeamKind.family:
        return 'Family';
      case TeamKind.company:
        return 'Company';
    }
  }

  static String _kindBadge(TeamKind kind) {
    switch (kind) {
      case TeamKind.friends:
        return 'Most Active';
      case TeamKind.family:
        return 'Weekly Goal On Track';
      case TeamKind.company:
        return 'Primary Team';
    }
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.68),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _TeamHeroCard extends StatelessWidget {
  const _TeamHeroCard({
    required this.activeTeams,
    required this.combinedMembers,
  });

  final String activeTeams;
  final String combinedMembers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(highlighted: true),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TeamScreen._mint.withOpacity(0.12),
              border: Border.all(
                color: TeamScreen._mint.withOpacity(0.22),
              ),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: TeamScreen._mint,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Build your impact circle',
                  style: TextStyle(
                    color: TeamScreen._textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create teams across close relationships and organizations, then turn collective movement into visible climate contribution.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _HeroMetric(
                        label: 'Active Teams',
                        value: activeTeams,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroMetric(
                        label: 'Combined Members',
                        value: combinedMembers,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.members,
    required this.co2Saved,
    required this.points,
    required this.steps,
    required this.accent,
    required this.badge,
    required this.kindLabel,
    required this.isPrimary,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String members;
  final String co2Saved;
  final String points;
  final String steps;
  final Color accent;
  final String badge;
  final String kindLabel;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(highlighted: isPrimary),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: accent.withOpacity(0.12),
                  border: Border.all(
                    color: accent.withOpacity(0.28),
                  ),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: TeamScreen._textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: accent.withOpacity(0.22),
                            ),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Text(
                            kindLabel,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.72),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Members',
                  value: members,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'Saved',
                  value: co2Saved,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Points',
                  value: points,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'Steps',
                  value: steps,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.56),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamInsightCard extends StatelessWidget {
  const _TeamInsightCard({
    required this.mostActiveGroup,
    required this.highestImpactUnit,
    required this.bestConsistencySignal,
  });

  final String mostActiveGroup;
  final String highestImpactUnit;
  final String bestConsistencySignal;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Dynamics',
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _SignalRow(
            label: 'Most active group',
            value: mostActiveGroup,
          ),
          const SizedBox(height: 10),
          _SignalRow(
            label: 'Highest impact unit',
            value: highestImpactUnit,
          ),
          const SizedBox(height: 10),
          _SignalRow(
            label: 'Best consistency signal',
            value: bestConsistencySignal,
          ),
        ],
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CreateTeamCard extends StatelessWidget {
  const _CreateTeamCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TeamScreen._mintStrong.withOpacity(0.12),
              border: Border.all(
                color: TeamScreen._mintStrong.withOpacity(0.22),
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: TeamScreen._mintStrong,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Team',
                  style: TextStyle(
                    color: TeamScreen._textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new team for friends, family, or company and prepare the structure for future invite and mission systems.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.60),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TeamScreen._mintStrong.withOpacity(0.12),
              border: Border.all(
                color: TeamScreen._mintStrong.withOpacity(0.22),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: TeamScreen._mintStrong,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coming next',
                  style: TextStyle(
                    color: TeamScreen._textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Team invites, private missions, sponsor-linked campaigns, and city-based climate competitions will connect here.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _panelDecoration({bool highlighted = false}) {
  return BoxDecoration(
    color: highlighted ? TeamScreen._panelStrong : TeamScreen._panel,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: highlighted
          ? TeamScreen._mint.withOpacity(0.18)
          : TeamScreen._border,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.18),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}