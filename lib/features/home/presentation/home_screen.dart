import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeron/widgets/zeron_background.dart';
import 'package:zeron/widgets/zeron_distortion.dart';
import 'package:zeron/widgets/zeron_glow.dart';
import 'package:zeron/widgets/zeron_logo.dart';
import 'package:zeron/widgets/zeron_noise.dart';

class ZeronHomeScreen extends StatefulWidget {
  const ZeronHomeScreen({super.key});

  @override
  State<ZeronHomeScreen> createState() => _ZeronHomeScreenState();
}

class _ZeronHomeScreenState extends State<ZeronHomeScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _openingDuration = Duration(milliseconds: 3600);
  static const String _termsAcceptedKey = 'zeron_terms_accepted_v1';

  late final AnimationController _openingController;
  Timer? _openingTimer;

  bool _showOpening = true;
  bool _termsChecked = false;

  @override
  void initState() {
    super.initState();

    _openingController = AnimationController(
      vsync: this,
      duration: _openingDuration,
    )..forward();

    _openingTimer = Timer(_openingDuration, _finishOpening);
  }

  @override
  void dispose() {
    _openingTimer?.cancel();
    _openingController.dispose();
    super.dispose();
  }

  Future<void> _finishOpening() async {
    if (!mounted || !_showOpening) return;

    setState(() {
      _showOpening = false;
    });

    await _ensureTermsAccepted();
  }

  Future<void> _ensureTermsAccepted() async {
    if (_termsChecked || !mounted) return;
    _termsChecked = true;

    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_termsAcceptedKey) ?? false;

    if (!mounted || accepted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TermsDialog(
        onAccept: () async {
          final localPrefs = await SharedPreferences.getInstance();
          await localPrefs.setBool(_termsAcceptedKey, true);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _skipOpening() {
    _openingTimer?.cancel();
    _openingController.stop();
    _finishOpening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _showOpening
            ? _OpeningScene(
                key: const ValueKey<String>('opening'),
                controller: _openingController,
                onSkip: _skipOpening,
              )
            : const _ZeronMainShell(
                key: ValueKey<String>('main-shell'),
              ),
      ),
    );
  }
}

class _OpeningScene extends StatelessWidget {
  const _OpeningScene({
    super.key,
    required this.controller,
    required this.onSkip,
  });

  final AnimationController controller;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final double t = controller.value;
        final double presenceSeconds = t * 6.0 + 0.15;
        final double backgroundOpacity =
            Curves.easeOutCubic.transform((t / 0.42).clamp(0.0, 1.0));
        final double glowOpacity =
            Curves.easeOutCubic.transform(((t - 0.16) / 0.34).clamp(0.0, 1.0));
        final double logoOpacity =
            Curves.easeOutCubic.transform(((t - 0.28) / 0.30).clamp(0.0, 1.0));
        final double titleOpacity =
            Curves.easeOutCubic.transform(((t - 0.44) / 0.24).clamp(0.0, 1.0));
        final double footerOpacity =
            Curves.easeOutCubic.transform(((t - 0.62) / 0.20).clamp(0.0, 1.0));
        final double drift = math.sin(presenceSeconds * 0.55) * 8.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSkip,
          child: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ZeronNoise(
                  presenceSeconds: presenceSeconds,
                  ambientStage: 2,
                  interactionEnergy: 0.08 + (t * 0.12),
                  isPointerInside: false,
                ),
                Opacity(
                  opacity: backgroundOpacity,
                  child: ZeronBackground(
                    presenceSeconds: presenceSeconds,
                    ambientStage: 2,
                    interactionEnergy: 0.10 + (t * 0.12),
                    pointerPosition: const Offset(0, 0),
                  ),
                ),
                Opacity(
                  opacity: glowOpacity,
                  child: ZeronDistortion(
                    presenceSeconds: presenceSeconds,
                    ambientStage: 2,
                    interactionEnergy: 0.12 + (t * 0.18),
                    pointerPosition: const Offset(0, 0),
                  ),
                ),
                Opacity(
                  opacity: glowOpacity,
                  child: ZeronGlow(
                    presenceSeconds: presenceSeconds,
                    ambientStage: 2,
                    interactionEnergy: 0.10 + (t * 0.12),
                    pointerPosition: const Offset(0, 0),
                    memoryPresence: 0.08,
                    memoryType: 'still',
                  ),
                ),
                Center(
                  child: Transform.translate(
                    offset: Offset(0, drift),
                    child: Opacity(
                      opacity: logoOpacity,
                      child: const ZeronLogo(
                        isIdle: false,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        Opacity(
                          opacity: titleOpacity,
                          child: const Text(
                            'ZERON',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 7,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Opacity(
                          opacity: footerOpacity,
                          child: Column(
                            children: [
                              const Text(
                                'WALK FOR EARTH',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFDEFBEA),
                                  fontSize: 11,
                                  letterSpacing: 3.6,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Global decarbonization participation interface',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.70),
                                  fontSize: 12,
                                  height: 1.45,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                child: Text(
                                  'Tap to skip',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.70),
                                    fontSize: 11,
                                    letterSpacing: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ZeronMainShell extends StatefulWidget {
  const _ZeronMainShell({super.key});

  @override
  State<_ZeronMainShell> createState() => _ZeronMainShellState();
}

class _ZeronMainShellState extends State<_ZeronMainShell> {
  int _currentIndex = 0;

  final _AppSnapshot _data = _AppSnapshot.demo();

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _TodayPage(data: _data),
      _DashboardPage(data: _data),
      _RankPage(data: _data),
      _AccountPage(data: _data),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF020406),
            Color(0xFF040A0E),
            Color(0xFF010203),
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ),
          _BottomBar(
            index: _currentIndex,
            onChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _TodayPage extends StatelessWidget {
  const _TodayPage({required this.data});

  final _AppSnapshot data;

  @override
  Widget build(BuildContext context) {
    final progress = (data.userStepsToday / data.dailyGoalSteps).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        const _PageHeader(
          title: 'Earth Today',
          subtitle: 'Every step joins the global decarbonization field.',
        ),
        const SizedBox(height: 18),
        _GlobeHero(
          title: '${_formatNumber(data.globalStepsToday)} steps',
          subtitle: 'Global steps today',
          centerLabel: '${_formatNumber(data.userStepsToday)}',
          bottomLabel: 'You helped Earth today',
          progress: progress,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'CO₂ Saved',
                value: '${data.userCo2Kg.toStringAsFixed(2)} kg',
                icon: Icons.eco_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Prime Points',
                value: _formatNumber(data.userPrimePoints),
                icon: Icons.bolt_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title: 'Monthly Event',
          value: data.monthlyEventTitle,
          icon: Icons.emoji_events_outlined,
          subtitle:
              '${data.monthlyEventDescription}\nEnds in ${data.eventDaysLeft} days',
        ),
        const SizedBox(height: 12),
        _ProgressCard(
          title: 'Daily Goal',
          current: data.userStepsToday,
          goal: data.dailyGoalSteps,
        ),
        const SizedBox(height: 12),
        _ActionCard(
          title: 'Why your steps matter',
          body:
              'ZERON converts walking into verified participation data for future sponsor rewards, monthly events, and carbon-credit linked initiatives.',
        ),
      ],
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({required this.data});

  final _AppSnapshot data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        const _PageHeader(
          title: 'Earth Dashboard',
          subtitle: 'Live view of users, steps, CO₂ reduction and momentum.',
        ),
        const SizedBox(height: 18),
        _DashboardHero(data: data),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Active Walkers',
                value: _formatNumber(data.activeWalkers),
                icon: Icons.groups_2_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Countries',
                value: _formatNumber(data.countriesActive),
                icon: Icons.public_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'This Month Steps',
                value: _formatNumber(data.globalStepsMonth),
                icon: Icons.bar_chart_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'CO₂ Saved',
                value: '${_formatNumber(data.globalCo2Kg)} kg',
                icon: Icons.forest_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Growth Signals',
          child: Column(
            children: [
              _SignalRow(
                label: 'Monthly active teams',
                value: _formatNumber(data.activeTeams),
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: 'Sponsor-ready participation pool',
                value: '${_formatNumber(data.sponsorReadyUsers)} users',
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: 'Reward reserve projection',
                value: '¥${_formatNumber(data.rewardPoolYen)}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankPage extends StatefulWidget {
  const _RankPage({required this.data});

  final _AppSnapshot data;

  @override
  State<_RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<_RankPage> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final labels = ['World', 'Country', 'City', 'Team'];
    final lists = [
      widget.data.worldRank,
      widget.data.countryRank,
      widget.data.cityRank,
      widget.data.teamRank,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        const _PageHeader(
          title: 'Rank',
          subtitle: 'Compete globally, nationally, locally and by team.',
        ),
        const SizedBox(height: 18),
        _SegmentBar(
          labels: labels,
          selectedIndex: _segment,
          onChanged: (index) {
            setState(() {
              _segment = index;
            });
          },
        ),
        const SizedBox(height: 16),
        _SummaryRankCard(
          title: 'Your Position',
          value: _segment == 0
              ? '#${widget.data.userWorldRank}'
              : _segment == 1
                  ? '#${widget.data.userCountryRank}'
                  : _segment == 2
                      ? '#${widget.data.userCityRank}'
                      : '#${widget.data.userTeamRank}',
          caption: _segment == 0
              ? 'World ranking'
              : _segment == 1
                  ? '${widget.data.country} ranking'
                  : _segment == 2
                      ? '${widget.data.city} ranking'
                      : 'Team ranking',
        ),
        const SizedBox(height: 16),
        ...List.generate(
          lists[_segment].length,
          (index) {
            final entry = lists[_segment][index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == lists[_segment].length - 1 ? 0 : 12,
              ),
              child: _RankTile(
                rank: index + 1,
                name: entry.name,
                value: entry.value,
                badge: entry.badge,
                highlighted: entry.highlighted,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AccountPage extends StatelessWidget {
  const _AccountPage({required this.data});

  final _AppSnapshot data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        const _PageHeader(
          title: 'Account',
          subtitle: 'Identity, permissions, legal status and membership.',
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Profile',
          child: Column(
            children: [
              _AccountRow(label: 'Email', value: data.email),
              const SizedBox(height: 14),
              _AccountRow(label: 'Country', value: data.country),
              const SizedBox(height: 14),
              _AccountRow(label: 'City', value: data.city),
              const SizedBox(height: 14),
              _AccountRow(label: 'Plan', value: data.planName),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'ZERON+',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock advanced ranking analytics, event boosts, sponsor campaign priority and future reward acceleration.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.74),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8FFE3).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFB8FFE3).withOpacity(0.18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_outlined,
                      color: Color(0xFFB8FFE3),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Subscription ready for sponsor and reward expansion',
                        style: TextStyle(
                          color: Color(0xFFEFFFF8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '¥980/mo',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.90),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Legal',
          child: Column(
            children: const [
              _SimpleArrowRow(label: 'Terms of Service'),
              SizedBox(height: 14),
              _SimpleArrowRow(label: 'Privacy Policy'),
              SizedBox(height: 14),
              _SimpleArrowRow(label: 'Anti-Cheat & Fair Use'),
              SizedBox(height: 14),
              _SimpleArrowRow(label: 'Sponsor Reward Policy'),
            ],
          ),
        ),
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

class _GlobeHero extends StatelessWidget {
  const _GlobeHero({
    required this.title,
    required this.subtitle,
    required this.centerLabel,
    required this.bottomLabel,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final String centerLabel;
  final String bottomLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFEAFBF2),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.60),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _EarthPainter(progress: progress),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'steps',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bottomLabel,
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.data});

  final _AppSnapshot data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Global Field',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_formatNumber(data.globalStepsToday)} steps',
            style: const TextStyle(
              color: Color(0xFFEAFBF2),
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          _MetricLine(
            label: 'Today CO₂ saved',
            value: '${_formatNumber(data.globalCo2Kg)} kg',
          ),
          const SizedBox(height: 10),
          _MetricLine(
            label: 'Reward points minted',
            value: _formatNumber(data.totalPrimePoints),
          ),
          const SizedBox(height: 10),
          _MetricLine(
            label: 'Cities active',
            value: _formatNumber(data.citiesActive),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFB8FFE3), size: 20),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.64),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.current,
    required this.goal,
  });

  final String title;
  final int current;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);

    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                _formatNumber(current),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' / ${_formatNumber(goal)} steps',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFB8FFE3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ZERON',
            style: TextStyle(
              color: Color(0xFFB8FFE3),
              fontSize: 11,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          child,
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

class _MetricLine extends StatelessWidget {
  const _MetricLine({
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
              color: Colors.white.withOpacity(0.66),
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List.generate(
          labels.length,
          (index) {
            final selected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFB8FFE3).withOpacity(0.13)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFB8FFE3).withOpacity(0.24)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFFEFFFF8)
                          : Colors.white.withOpacity(0.60),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRankCard extends StatelessWidget {
  const _SummaryRankCard({
    required this.title,
    required this.value,
    required this.caption,
  });

  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFB8FFE3).withOpacity(0.12),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Color(0xFFB8FFE3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.64),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.60),
                    fontSize: 12,
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

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.rank,
    required this.name,
    required this.value,
    required this.badge,
    required this.highlighted,
  });

  final int rank;
  final String name;
  final String value;
  final String badge;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(
        highlighted: highlighted,
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted
                  ? const Color(0xFFB8FFE3).withOpacity(0.16)
                  : Colors.white.withOpacity(0.06),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                color: highlighted
                    ? const Color(0xFFEFFFF8)
                    : Colors.white.withOpacity(0.82),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFEAFBF2),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleArrowRow extends StatelessWidget {
  const _SimpleArrowRow({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: Colors.white.withOpacity(0.60),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_BottomBarItem>[
      const _BottomBarItem('Today', Icons.home_filled),
      const _BottomBarItem('Dashboard', Icons.public),
      const _BottomBarItem('Rank', Icons.bar_chart_rounded),
      const _BottomBarItem('Account', Icons.person_rounded),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF091015).withOpacity(0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.32),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            items.length,
            (i) {
              final selected = index == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFB8FFE3).withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[i].icon,
                          color: selected
                              ? const Color(0xFFB8FFE3)
                              : Colors.white.withOpacity(0.58),
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFFEFFFF8)
                                : Colors.white.withOpacity(0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TermsDialog extends StatelessWidget {
  const _TermsDialog({
    required this.onAccept,
  });

  final Future<void> Function() onAccept;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF091015),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Terms of Service',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'ZERON records walking participation, account identity, anti-cheat data, and regional ranking information to operate global decarbonization events and future sponsor rewards.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.74),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB8FFE3).withOpacity(0.14),
                  foregroundColor: const Color(0xFFEFFFF8),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: const Color(0xFFB8FFE3).withOpacity(0.22),
                    ),
                  ),
                ),
                onPressed: () async {
                  await onAccept();
                },
                child: const Text(
                  'I Accept',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem {
  const _BottomBarItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _RankEntry {
  const _RankEntry({
    required this.name,
    required this.value,
    required this.badge,
    this.highlighted = false,
  });

  final String name;
  final String value;
  final String badge;
  final bool highlighted;
}

class _AppSnapshot {
  const _AppSnapshot({
    required this.email,
    required this.country,
    required this.city,
    required this.planName,
    required this.userStepsToday,
    required this.userCo2Kg,
    required this.userPrimePoints,
    required this.userWorldRank,
    required this.userCountryRank,
    required this.userCityRank,
    required this.userTeamRank,
    required this.globalStepsToday,
    required this.globalStepsMonth,
    required this.globalCo2Kg,
    required this.totalPrimePoints,
    required this.activeWalkers,
    required this.activeTeams,
    required this.countriesActive,
    required this.citiesActive,
    required this.sponsorReadyUsers,
    required this.rewardPoolYen,
    required this.dailyGoalSteps,
    required this.monthlyEventTitle,
    required this.monthlyEventDescription,
    required this.eventDaysLeft,
    required this.worldRank,
    required this.countryRank,
    required this.cityRank,
    required this.teamRank,
  });

  final String email;
  final String country;
  final String city;
  final String planName;
  final int userStepsToday;
  final double userCo2Kg;
  final int userPrimePoints;
  final int userWorldRank;
  final int userCountryRank;
  final int userCityRank;
  final int userTeamRank;
  final int globalStepsToday;
  final int globalStepsMonth;
  final int globalCo2Kg;
  final int totalPrimePoints;
  final int activeWalkers;
  final int activeTeams;
  final int countriesActive;
  final int citiesActive;
  final int sponsorReadyUsers;
  final int rewardPoolYen;
  final int dailyGoalSteps;
  final String monthlyEventTitle;
  final String monthlyEventDescription;
  final int eventDaysLeft;
  final List<_RankEntry> worldRank;
  final List<_RankEntry> countryRank;
  final List<_RankEntry> cityRank;
  final List<_RankEntry> teamRank;

  factory _AppSnapshot.demo() {
    return const _AppSnapshot(
      email: 'your.email@example.com',
      country: 'Japan',
      city: 'Tokyo',
      planName: 'Free',
      userStepsToday: 8420,
      userCo2Kg: 1.24,
      userPrimePoints: 421,
      userWorldRank: 124432,
      userCountryRank: 1522,
      userCityRank: 18,
      userTeamRank: 4,
      globalStepsToday: 4245332000,
      globalStepsMonth: 91245000000,
      globalCo2Kg: 845000,
      totalPrimePoints: 15842000,
      activeWalkers: 2340000,
      activeTeams: 42550,
      countriesActive: 118,
      citiesActive: 3240,
      sponsorReadyUsers: 684000,
      rewardPoolYen: 12500000,
      dailyGoalSteps: 10000,
      monthlyEventTitle: 'March Earth Pulse',
      monthlyEventDescription:
          'Walk together to unlock sponsor-backed reward tiers and global city rankings.',
      eventDaysLeft: 11,
      worldRank: [
        _RankEntry(
          name: 'neo.rearri@example.com',
          value: '124,432',
          badge: 'Top global walker',
        ),
        _RankEntry(
          name: 'Cocoro S.',
          value: '8,420',
          badge: 'ZERON Tokyo',
          highlighted: true,
        ),
        _RankEntry(
          name: 'Aster Vale',
          value: '8,118',
          badge: 'United States',
        ),
        _RankEntry(
          name: 'Eon Loop',
          value: '7,980',
          badge: 'Germany',
        ),
      ],
      countryRank: [
        _RankEntry(
          name: 'Japan',
          value: '4,245,332,000',
          badge: 'Country steps rank',
        ),
        _RankEntry(
          name: 'Cocoro S.',
          value: '8,420',
          badge: 'Tokyo',
          highlighted: true,
        ),
        _RankEntry(
          name: 'Kyoto Walker',
          value: '8,050',
          badge: 'Kyoto',
        ),
        _RankEntry(
          name: 'Sapporo Run',
          value: '7,944',
          badge: 'Sapporo',
        ),
      ],
      cityRank: [
        _RankEntry(
          name: 'Tokyo',
          value: '18',
          badge: 'City position',
        ),
        _RankEntry(
          name: 'Cocoro S.',
          value: '8,420',
          badge: 'Tokyo rank #18',
          highlighted: true,
        ),
        _RankEntry(
          name: 'Minato Walker',
          value: '8,310',
          badge: 'Tokyo',
        ),
        _RankEntry(
          name: 'Shibuya Pulse',
          value: '8,088',
          badge: 'Tokyo',
        ),
      ],
      teamRank: [
        _RankEntry(
          name: 'Friends Team',
          value: '53,000',
          badge: 'Team steps',
        ),
        _RankEntry(
          name: 'Family Team',
          value: '47,500',
          badge: 'Team steps',
        ),
        _RankEntry(
          name: 'Company Team',
          value: '41,500',
          badge: 'Team steps',
        ),
        _RankEntry(
          name: 'ZERON Tokyo',
          value: '38,200',
          badge: 'Your current team',
          highlighted: true,
        ),
      ],
    );
  }
}

class _EarthPainter extends CustomPainter {
  const _EarthPainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.36;
    final rect = Offset.zero & size;

    final bg = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF0C1A1A),
          Color(0xFF061012),
          Colors.transparent,
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, bg);

    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
      ..color = const Color(0xFF9DFFE3).withOpacity(0.18);

    canvas.drawCircle(center, radius * 1.05, glow);

    final earth = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.18, -0.22),
        radius: 0.96,
        colors: [
          const Color(0xFF76FFD8).withOpacity(0.85),
          const Color(0xFF1A3E46).withOpacity(0.92),
          const Color(0xFF091319),
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, earth);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFB8FFE3).withOpacity(0.20);

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(center, radius + (14 * (i + 1)), ringPaint);
    }

    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFFB8FFE3).withOpacity(0.18);

    final orbitRect = Rect.fromCenter(
      center: center,
      width: radius * 2.7,
      height: radius * 1.05,
    );
    canvas.drawOval(orbitRect, orbit);

    final progressArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..shader = const SweepGradient(
        colors: [
          Color(0x00B8FFE3),
          Color(0xFFB8FFE3),
          Color(0x00B8FFE3),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius + 22),
      );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 22),
      -math.pi / 2,
      (math.pi * 2) * progress,
      false,
      progressArc,
    );

    final stars = Paint()..color = Colors.white.withOpacity(0.50);
    final random = math.Random(77);

    for (int i = 0; i < 36; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final d = (Offset(dx, dy) - center).distance;
      if (d > radius * 1.15) {
        canvas.drawCircle(Offset(dx, dy), 0.8 + random.nextDouble(), stars);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EarthPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

BoxDecoration _panelDecoration({bool highlighted = false}) {
  return BoxDecoration(
    color: highlighted
        ? const Color(0xFF0E181A)
        : const Color(0xFF091015).withOpacity(0.92),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: highlighted
          ? const Color(0xFFB8FFE3).withOpacity(0.20)
          : Colors.white.withOpacity(0.08),
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