import 'package:flutter/material.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  static const Color _panel = Color(0xFF091015);
  static const Color _panelStrong = Color(0xFF0E181A);
  static const Color _border = Color(0x14FFFFFF);
  static const Color _mint = Color(0xFFB8FFE3);
  static const Color _mintStrong = Color(0xFF79F7D4);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xB3FFFFFF);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: const [
        SizedBox(height: 6),
        _PageHeader(
          title: 'Team',
          subtitle:
              'Build shared momentum with friends, family, and companies through collective walking impact.',
        ),
        SizedBox(height: 18),
        _TeamHeroCard(),
        SizedBox(height: 16),
        _TeamCard(
          title: 'Friends Team',
          subtitle:
              'Turn casual walks into a shared challenge and keep motivation high with weekly movement goals.',
          icon: Icons.diversity_3_rounded,
          members: '12 members',
          co2Saved: '34.8 kg CO₂',
          points: '4,820 Prime Points',
          steps: '53,000 steps',
          accent: Color(0xFF79F7D4),
          badge: 'Most Active',
        ),
        SizedBox(height: 16),
        _TeamCard(
          title: 'Family Team',
          subtitle:
              'Make daily health routines visible across your family and grow climate participation together.',
          icon: Icons.favorite_rounded,
          members: '5 members',
          co2Saved: '12.6 kg CO₂',
          points: '1,940 Prime Points',
          steps: '47,500 steps',
          accent: Color(0xFF8CD8FF),
          badge: 'Weekly Goal On Track',
        ),
        SizedBox(height: 16),
        _TeamCard(
          title: 'Company Team',
          subtitle:
              'Scale workplace engagement and show how organizational movement can contribute to global impact.',
          icon: Icons.apartment_rounded,
          members: '48 members',
          co2Saved: '128.4 kg CO₂',
          points: '16,300 Prime Points',
          steps: '382,000 steps',
          accent: Color(0xFFFFC978),
          badge: 'Top Ranked',
        ),
        SizedBox(height: 16),
        _TeamInsightCard(),
        SizedBox(height: 16),
        _ComingSoonCard(),
      ],
    );
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
  const _TeamHeroCard();

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
                  children: const [
                    Expanded(
                      child: _HeroMetric(
                        label: 'Active Teams',
                        value: '3',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _HeroMetric(
                        label: 'Combined Members',
                        value: '65',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
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
                  accent: accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'Saved',
                  value: co2Saved,
                  accent: accent,
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
                  accent: accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'Steps',
                  value: steps,
                  accent: accent,
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
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

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
  const _TeamInsightCard();

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
          const _SignalRow(
            label: 'Most active group',
            value: 'Friends Team',
          ),
          const SizedBox(height: 10),
          const _SignalRow(
            label: 'Highest impact unit',
            value: 'Company Team',
          ),
          const SizedBox(height: 10),
          const _SignalRow(
            label: 'Best consistency signal',
            value: 'Family Team',
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