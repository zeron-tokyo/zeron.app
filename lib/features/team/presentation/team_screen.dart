import 'package:flutter/material.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  static const Color _bgTop = Color(0xFF07131A);
  static const Color _bgBottom = Color(0xFF020608);
  static const Color _card = Color(0xFF0D1B22);
  static const Color _cardBorder = Color(0xFF1C3A43);
  static const Color _mint = Color(0xFF79F7D4);
  static const Color _mintSoft = Color(0xFFB8FFF0);
  static const Color _textPrimary = Color(0xFFF3FFFB);
  static const Color _textSecondary = Color(0xFF9FB7B4);
  static const Color _chipBg = Color(0x1429E7C5);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: _textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Walk together, reduce more, and turn daily movement into shared climate action.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _card.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _cardBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _chipBg,
                              border: Border.all(
                                color: _mint.withValues(alpha: 0.35),
                              ),
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              color: _mint,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Build your impact circle',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: _textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Create or join teams for friends, family, and your company to climb the leaderboard together.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  const [
                    _TeamCard(
                      title: 'Friends Team',
                      subtitle:
                          'Turn casual walks into a shared challenge with close friends.',
                      icon: Icons.diversity_3_rounded,
                      members: '12 members',
                      co2Saved: '34.8 kg CO₂',
                      points: '4,820 Prime Points',
                      accent: Color(0xFF79F7D4),
                      badge: 'Most Active',
                    ),
                    SizedBox(height: 16),
                    _TeamCard(
                      title: 'Family Team',
                      subtitle:
                          'Make healthy routines visible across your family each week.',
                      icon: Icons.favorite_rounded,
                      members: '5 members',
                      co2Saved: '12.6 kg CO₂',
                      points: '1,940 Prime Points',
                      accent: Color(0xFF8CD8FF),
                      badge: 'Weekly Goal On Track',
                    ),
                    SizedBox(height: 16),
                    _TeamCard(
                      title: 'Company Team',
                      subtitle:
                          'Motivate workplace participation and scale climate action together.',
                      icon: Icons.apartment_rounded,
                      members: '48 members',
                      co2Saved: '128.4 kg CO₂',
                      points: '16,300 Prime Points',
                      accent: Color(0xFFFFC978),
                      badge: 'Top Ranked',
                    ),
                    SizedBox(height: 18),
                    _ComingSoonCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String members;
  final String co2Saved;
  final String points;
  final Color accent;
  final String badge;

  const _TeamCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.members,
    required this.co2Saved,
    required this.points,
    required this.accent,
    required this.badge,
  });

  static const Color _card = Color(0xFF0D1B22);
  static const Color _border = Color(0xFF1C3A43);
  static const Color _textPrimary = Color(0xFFF3FFFB);
  static const Color _textSecondary = Color(0xFF9FB7B4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
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
                  color: accent.withValues(alpha: 0.12),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: accent.withValues(alpha: 0.28)),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
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
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
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
          _StatPill(
            label: 'Points',
            value: points,
            accent: accent,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool fullWidth;

  const _StatPill({
    required this.label,
    required this.value,
    required this.accent,
    this.fullWidth = false,
  });

  static const Color _bg = Color(0xFF102029);
  static const Color _border = Color(0xFF1F3941);
  static const Color _textPrimary = Color(0xFFF3FFFB);
  static const Color _textSecondary = Color(0xFF8CA8A4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: _textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  static const Color _card = Color(0xFF0B161C);
  static const Color _border = Color(0xFF193039);
  static const Color _mint = Color(0xFF79F7D4);
  static const Color _textPrimary = Color(0xFFF3FFFB);
  static const Color _textSecondary = Color(0xFF9FB7B4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _mint.withValues(alpha: 0.12),
              border: Border.all(color: _mint.withValues(alpha: 0.35)),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: _mint,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coming next',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Team invites, private challenges, sponsor missions, and city-based climate competitions will be connected here.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _textSecondary,
                    height: 1.5,
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