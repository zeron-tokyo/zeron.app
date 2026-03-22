import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeron/core/models/app_models.dart';
import 'package:zeron/core/services/step_service.dart';
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

  bool _showOpening = true;
  bool _isCheckingTerms = false;
  bool _termsAccepted = false;
  bool _isEntering = false;

  @override
  void initState() {
    super.initState();

    _openingController = AnimationController(
      vsync: this,
      duration: _openingDuration,
    )..forward();

    _loadTermsState();
  }

  @override
  void dispose() {
    _openingController.dispose();
    super.dispose();
  }

  Future<void> _loadTermsState() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_termsAcceptedKey) ?? false;
    if (!mounted) return;
    setState(() {
      _termsAccepted = accepted;
    });
  }

  Future<void> _finishOpening() async {
    if (!mounted || !_showOpening || _isEntering) return;

    _isEntering = true;

    await _ensureTermsAccepted();
    if (!mounted) return;

    setState(() {
      _showOpening = false;
    });

    _isEntering = false;
  }

  Future<void> _ensureTermsAccepted() async {
    if (!mounted || _termsAccepted || _isCheckingTerms) return;

    _isCheckingTerms = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _TermsDialog(
          onAccept: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_termsAcceptedKey, true);

            if (mounted) {
              setState(() {
                _termsAccepted = true;
              });
            }

            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );

    _isCheckingTerms = false;
  }

  void _skipOpening() {
    _finishOpening();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          child: ColoredBox(
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
                      child: const ZeronLogo(isIdle: false),
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
                        const SizedBox(height: 18),
                        Opacity(
                          opacity: titleOpacity,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              _OpeningChip(label: 'Version 1.0.0'),
                              _OpeningChip(label: 'Settings inside Account'),
                              _OpeningChip(label: 'Account ready'),
                            ],
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
                                  'Tap to enter',
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

class _OpeningChip extends StatelessWidget {
  const _OpeningChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.76),
          fontSize: 10.5,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ZeronMainShell extends StatefulWidget {
  const _ZeronMainShell({super.key});

  @override
  State<_ZeronMainShell> createState() => _ZeronMainShellState();
}

class _ZeronMainShellState extends State<_ZeronMainShell> {
  static const String _languageKey = 'zeron_language_v1';
  static const String _soundKey = 'zeron_sound_v1';
  static const String _notificationsKey = 'zeron_notifications_v1';

  int _currentIndex = 0;
  String _language = 'en';
  bool _soundOn = true;
  bool _notificationsOn = true;

  late ZeronUser _user;
  late DailyImpactSummary _todaySummary;
  late GlobalImpactSnapshot _global;
  late TeamModel _primaryTeam;
  late TeamModel _friendsTeam;
  late TeamModel _familyTeam;
  late TeamModel _companyTeam;
  late List<RankEntryModel> _worldRank;
  late List<RankEntryModel> _countryRank;
  late List<RankEntryModel> _cityRank;
  late List<RankEntryModel> _teamRank;
  late String _monthlyEventTitle;
  late String _monthlyEventDescription;
  late int _eventDaysLeft;
  late int _sponsorReadyUsers;

  late int _baseTotalSteps;
  late double _baseTotalCo2KgSaved;
  late int _baseTotalPrimePoints;

  StreamSubscription<int>? _stepSubscription;
  Timer? _ambientTimer;

  double _presenceSeconds = 0.0;
  double _interactionEnergy = 0.10;
  bool _isPointerInside = false;
  Offset _pointerPosition = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
    StepService.init();
    _initData();
    _loadSettings();
    _bindStepStream();
    _startAmbientTimer();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _ambientTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _language = prefs.getString(_languageKey) ?? 'en';
      _soundOn = prefs.getBool(_soundKey) ?? true;
      _notificationsOn = prefs.getBool(_notificationsKey) ?? true;
    });
  }

  Future<void> _setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
    if (!mounted) return;
    setState(() {
      _language = value;
    });
  }

  Future<void> _setSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
    if (!mounted) return;
    setState(() {
      _soundOn = value;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    if (!mounted) return;
    setState(() {
      _notificationsOn = value;
    });
  }

  String _t(String en, String ja) => _language == 'ja' ? ja : en;

  void _startAmbientTimer() {
    _ambientTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() {
        _presenceSeconds += 0.08;
        _interactionEnergy = _isPointerInside
            ? (_interactionEnergy + 0.010).clamp(0.08, 0.60)
            : (_interactionEnergy - 0.008).clamp(0.08, 0.22);
      });
    });
  }

  void _initData() {
    final now = DateTime.now();

    _baseTotalSteps = 1245820;
    _baseTotalCo2KgSaved = ZeronImpactCalculator.calculateCo2KgSavedFromSteps(
      _baseTotalSteps,
    );
    _baseTotalPrimePoints = 58240;

    _todaySummary = StepService.buildSummary(0);

    _user = ZeronUser(
      id: 'user_cocoro_demo',
      email: 'your.email@example.com',
      countryCode: 'JP',
      countryName: 'Japan',
      city: 'Tokyo',
      plan: ZeronPlan.free,
      termsAccepted: true,
      createdAt: now.subtract(const Duration(days: 180)),
      updatedAt: now,
      displayName: 'Cocoro S.',
      primaryTeamId: 'team_company_zeron_tokyo',
      totalSteps: _baseTotalSteps,
      totalCo2KgSaved: _baseTotalCo2KgSaved,
      totalPrimePoints: _baseTotalPrimePoints,
      todaySteps: 0,
      todayCo2KgSaved: 0,
      todayPrimePoints: 0,
      worldRank: 124432,
      countryRank: 1522,
      cityRank: 18,
      teamRank: 4,
    );

    _friendsTeam = TeamModel(
      id: 'team_friends',
      name: 'Friends Team',
      kind: TeamKind.friends,
      ownerUserId: _user.id,
      memberCount: 12,
      totalSteps: 53000,
      totalCo2KgSaved: ZeronImpactCalculator.calculateCo2KgSavedFromSteps(
        53000,
      ),
      totalPrimePoints: 4820,
      createdAt: now.subtract(const Duration(days: 80)),
      updatedAt: now,
      description: 'Close friends walking together for weekly impact.',
      countryCode: 'JP',
      city: 'Tokyo',
    );

    _familyTeam = TeamModel(
      id: 'team_family',
      name: 'Family Team',
      kind: TeamKind.family,
      ownerUserId: _user.id,
      memberCount: 5,
      totalSteps: 47500,
      totalCo2KgSaved: ZeronImpactCalculator.calculateCo2KgSavedFromSteps(
        47500,
      ),
      totalPrimePoints: 1940,
      createdAt: now.subtract(const Duration(days: 120)),
      updatedAt: now,
      description: 'Family movement and shared health participation.',
      countryCode: 'JP',
      city: 'Tokyo',
    );

    _companyTeam = TeamModel(
      id: 'team_company_zeron_tokyo',
      name: 'Company Team',
      kind: TeamKind.company,
      ownerUserId: _user.id,
      memberCount: 48,
      totalSteps: 38200,
      totalCo2KgSaved: ZeronImpactCalculator.calculateCo2KgSavedFromSteps(
        38200,
      ),
      totalPrimePoints: 16300,
      createdAt: now.subtract(const Duration(days: 160)),
      updatedAt: now,
      description: 'Workplace climate participation unit.',
      countryCode: 'JP',
      city: 'Tokyo',
    );

    _primaryTeam = _companyTeam;

    _global = GlobalImpactSnapshot(
      activeUsers: 2340000,
      activeTeams: 42550,
      activeCountries: 118,
      activeCities: 3240,
      totalStepsToday: 4245332000,
      totalStepsThisMonth: 91245000000,
      totalCo2KgSaved: ZeronImpactCalculator.calculateCo2KgSavedFromSteps(
        4245332000,
      ),
      totalPrimePoints: 15842000,
      rewardPoolYen: 12500000,
      updatedAt: now,
    );

    _worldRank = <RankEntryModel>[
      const RankEntryModel(
        id: 'world_1',
        scope: RankScope.world,
        rank: 1,
        name: 'neo.rearri@example.com',
        value: 124432,
        label: 'Top global walker',
      ),
      RankEntryModel(
        id: 'world_2',
        scope: RankScope.world,
        rank: 2,
        name: _user.displayName ?? 'You',
        value: _user.todaySteps,
        label: 'ZERON Tokyo',
        isCurrentUser: true,
        relatedUserId: _user.id,
      ),
      const RankEntryModel(
        id: 'world_3',
        scope: RankScope.world,
        rank: 3,
        name: 'Aster Vale',
        value: 8118,
        label: 'United States',
      ),
      const RankEntryModel(
        id: 'world_4',
        scope: RankScope.world,
        rank: 4,
        name: 'Eon Loop',
        value: 7980,
        label: 'Germany',
      ),
    ];

    _countryRank = <RankEntryModel>[
      const RankEntryModel(
        id: 'country_1',
        scope: RankScope.country,
        rank: 1,
        name: 'Japan',
        value: 4245332000,
        label: 'Country steps rank',
      ),
      RankEntryModel(
        id: 'country_2',
        scope: RankScope.country,
        rank: 2,
        name: _user.displayName ?? 'You',
        value: _user.todaySteps,
        label: 'Tokyo',
        isCurrentUser: true,
        relatedUserId: _user.id,
      ),
      const RankEntryModel(
        id: 'country_3',
        scope: RankScope.country,
        rank: 3,
        name: 'Kyoto Walker',
        value: 8050,
        label: 'Kyoto',
      ),
      const RankEntryModel(
        id: 'country_4',
        scope: RankScope.country,
        rank: 4,
        name: 'Sapporo Run',
        value: 7944,
        label: 'Sapporo',
      ),
    ];

    _cityRank = <RankEntryModel>[
      const RankEntryModel(
        id: 'city_1',
        scope: RankScope.city,
        rank: 1,
        name: 'Tokyo',
        value: 18,
        label: 'City position',
      ),
      RankEntryModel(
        id: 'city_2',
        scope: RankScope.city,
        rank: 2,
        name: _user.displayName ?? 'You',
        value: _user.todaySteps,
        label: 'Tokyo rank #18',
        isCurrentUser: true,
        relatedUserId: _user.id,
      ),
      const RankEntryModel(
        id: 'city_3',
        scope: RankScope.city,
        rank: 3,
        name: 'Minato Walker',
        value: 8310,
        label: 'Tokyo',
      ),
      const RankEntryModel(
        id: 'city_4',
        scope: RankScope.city,
        rank: 4,
        name: 'Shibuya Pulse',
        value: 8088,
        label: 'Tokyo',
      ),
    ];

    _teamRank = <RankEntryModel>[
      RankEntryModel(
        id: 'team_1',
        scope: RankScope.team,
        rank: 1,
        name: _friendsTeam.name,
        value: _friendsTeam.totalSteps,
        label: 'Team steps',
        relatedTeamId: _friendsTeam.id,
      ),
      RankEntryModel(
        id: 'team_2',
        scope: RankScope.team,
        rank: 2,
        name: _familyTeam.name,
        value: _familyTeam.totalSteps,
        label: 'Team steps',
        relatedTeamId: _familyTeam.id,
      ),
      RankEntryModel(
        id: 'team_3',
        scope: RankScope.team,
        rank: 3,
        name: _companyTeam.name,
        value: 41500,
        label: 'Team steps',
        relatedTeamId: _companyTeam.id,
      ),
      RankEntryModel(
        id: 'team_4',
        scope: RankScope.team,
        rank: 4,
        name: 'ZERON Tokyo',
        value: _companyTeam.totalSteps,
        label: 'Your current team',
        isCurrentUser: true,
        relatedTeamId: _companyTeam.id,
      ),
    ];

    _monthlyEventTitle = 'March Earth Pulse';
    _monthlyEventDescription =
        'Walk together to unlock sponsor-backed reward tiers and global city rankings.';
    _eventDaysLeft = 11;
    _sponsorReadyUsers = 684000;
  }

  void _bindStepStream() {
    _stepSubscription = StepService.stepStream.listen((steps) {
      if (!mounted) return;

      final summary = StepService.buildSummary(steps);
      final updatedUser = _buildUserFromSummary(summary);

      setState(() {
        _todaySummary = summary;
        _user = updatedUser;
        _refreshRanks();
      });
    });
  }

  ZeronUser _buildUserFromSummary(DailyImpactSummary summary) {
    return _user.copyWith(
      todaySteps: summary.totalSteps,
      todayCo2KgSaved: summary.totalCo2KgSaved,
      todayPrimePoints: summary.totalPrimePoints,
      totalSteps: _baseTotalSteps + summary.totalSteps,
      totalCo2KgSaved: _baseTotalCo2KgSaved + summary.totalCo2KgSaved,
      totalPrimePoints: _baseTotalPrimePoints + summary.totalPrimePoints,
      updatedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  void _refreshRanks() {
    _worldRank = <RankEntryModel>[
      const RankEntryModel(
        id: 'world_1',
        scope: RankScope.world,
        rank: 1,
        name: 'neo.rearri@example.com',
        value: 124432,
        label: 'Top global walker',
      ),
      RankEntryModel(
        id: 'world_2',
        scope: RankScope.world,
        rank: 2,
        name: _user.displayName ?? 'You',
        value: _user.todaySteps,
        label: 'ZERON Tokyo',
        isCurrentUser: true,
        relatedUserId: _user.id,
      ),
      const RankEntryModel(
        id: 'world_3',
        scope: RankScope.world,
        rank: 3,
        name: 'Aster Vale',
        value: 8118,
        label: 'United States',
      ),
      const RankEntryModel(
        id: 'world_4',
        scope: RankScope.world,
        rank: 4,
        name: 'Eon Loop',
        value: 7980,
        label: 'Germany',
      ),
    ];

    _countryRank = <RankEntryModel>[
      const RankEntryModel(
        id: 'country_1',
        scope: RankScope.country,
        rank: 1,
        name: 'Japan',
        value: 4245332000,
        label: 'Country steps rank',
      ),
      RankEntryModel(
        id: 'country_2',
        scope: RankScope.country,
        rank: 2,
        name: _user.displayName ?? 'You',
        value: _user.todaySteps,
        label: 'Tokyo',
        isCurrentUser: true,
        relatedUserId: _user.id,
      ),
      const RankEntryModel(
        id: 'country_3',
        scope: RankScope.country,
        rank: 3,
        name: 'Kyoto Walker',
        value: 8050,
        label: 'Kyoto',
      ),
      const RankEntryModel(
        id: 'country_4',
        scope: RankScope.country,
        rank: 4,
        name: 'Sapporo Run',
        value: 7944,
        label: 'Sapporo',
      ),
    ];

    _cityRank = <RankEntryModel>[
      const RankEntryModel(
        id: 'city_1',
        scope: RankScope.city,
        rank: 1,
        name: 'Tokyo',
        value: 18,
        label: 'City position',
      ),
      RankEntryModel(
        id: 'city_2',
        scope: RankScope.city,
        rank: 2,
        name: _user.displayName ?? 'You',
        value: _user.todaySteps,
        label: 'Tokyo rank #18',
        isCurrentUser: true,
        relatedUserId: _user.id,
      ),
      const RankEntryModel(
        id: 'city_3',
        scope: RankScope.city,
        rank: 3,
        name: 'Minato Walker',
        value: 8310,
        label: 'Tokyo',
      ),
      const RankEntryModel(
        id: 'city_4',
        scope: RankScope.city,
        rank: 4,
        name: 'Shibuya Pulse',
        value: 8088,
        label: 'Tokyo',
      ),
    ];

    _teamRank = <RankEntryModel>[
      RankEntryModel(
        id: 'team_1',
        scope: RankScope.team,
        rank: 1,
        name: _friendsTeam.name,
        value: _friendsTeam.totalSteps,
        label: 'Team steps',
        relatedTeamId: _friendsTeam.id,
      ),
      RankEntryModel(
        id: 'team_2',
        scope: RankScope.team,
        rank: 2,
        name: _familyTeam.name,
        value: _familyTeam.totalSteps,
        label: 'Team steps',
        relatedTeamId: _familyTeam.id,
      ),
      RankEntryModel(
        id: 'team_3',
        scope: RankScope.team,
        rank: 3,
        name: _companyTeam.name,
        value: 41500,
        label: 'Team steps',
        relatedTeamId: _companyTeam.id,
      ),
      RankEntryModel(
        id: 'team_4',
        scope: RankScope.team,
        rank: 4,
        name: 'ZERON Tokyo',
        value: _companyTeam.totalSteps,
        label: 'Your current team',
        isCurrentUser: true,
        relatedTeamId: _companyTeam.id,
      ),
    ];
  }

  _HomeDemoState _viewState() {
    return _HomeDemoState(
      user: _user,
      todaySummary: _todaySummary,
      global: _global,
      primaryTeam: _primaryTeam,
      friendsTeam: _friendsTeam,
      familyTeam: _familyTeam,
      companyTeam: _companyTeam,
      worldRank: _worldRank,
      countryRank: _countryRank,
      cityRank: _cityRank,
      teamRank: _teamRank,
      monthlyEventTitle: _monthlyEventTitle,
      monthlyEventDescription: _monthlyEventDescription,
      eventDaysLeft: _eventDaysLeft,
      sponsorReadyUsers: _sponsorReadyUsers,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _viewState();

    final pages = <Widget>[
      _TodayPage(data: data, t: _t),
      _DashboardPage(data: data, t: _t),
      _RankPage(data: data, t: _t),
      _TeamPage(data: data, t: _t),
      _AccountPage(
        data: data,
        t: _t,
        language: _language,
        soundOn: _soundOn,
        notificationsOn: _notificationsOn,
        onSetLanguage: _setLanguage,
        onSetSound: _setSound,
        onSetNotifications: _setNotifications,
      ),
    ];

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isPointerInside = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isPointerInside = false;
          _pointerPosition = const Offset(0, 0);
        });
      },
      onHover: (event) {
        setState(() {
          _pointerPosition = event.localPosition;
          _interactionEnergy = (_interactionEnergy + 0.02).clamp(0.08, 0.60);
        });
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: ZeronNoise(
                presenceSeconds: _presenceSeconds,
                ambientStage: 2,
                interactionEnergy: _interactionEnergy,
                isPointerInside: _isPointerInside,
              ),
            ),
            IgnorePointer(
              child: ZeronBackground(
                presenceSeconds: _presenceSeconds,
                ambientStage: 2,
                interactionEnergy: _interactionEnergy,
                pointerPosition: _pointerPosition,
              ),
            ),
            IgnorePointer(
              child: ZeronDistortion(
                presenceSeconds: _presenceSeconds,
                ambientStage: 2,
                interactionEnergy: _interactionEnergy,
                pointerPosition: _pointerPosition,
              ),
            ),
            IgnorePointer(
              child: ZeronGlow(
                presenceSeconds: _presenceSeconds,
                ambientStage: 2,
                interactionEnergy: _interactionEnergy,
                pointerPosition: _pointerPosition,
                memoryPresence: 0.10,
                memoryType: _isPointerInside ? 'active' : 'still',
              ),
            ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF020406).withOpacity(0.60),
                      const Color(0xFF040A0E).withOpacity(0.52),
                      const Color(0xFF010203).withOpacity(0.78),
                    ],
                  ),
                ),
              ),
            ),
            Column(
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
                  labelBuilder: _navLabel,
                  onChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _navLabel(int index) {
    switch (index) {
      case 0:
        return _t('Today', '今日');
      case 1:
        return _t('Dashboard', 'ダッシュボード');
      case 2:
        return _t('Rank', 'ランク');
      case 3:
        return _t('Team', 'チーム');
      case 4:
        return _t('Account', 'アカウント');
      default:
        return '';
    }
  }
}

class _TodayPage extends StatelessWidget {
  const _TodayPage({
    required this.data,
    required this.t,
  });

  final _HomeDemoState data;
  final String Function(String en, String ja) t;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        _PageHeader(
          title: t('Today', '今日'),
          subtitle: t(
            'Every step joins the global decarbonization field.',
            '一歩ごとの行動が、世界の脱炭素フィールドに接続されます。',
          ),
        ),
        const SizedBox(height: 18),
        _GlobeHero(
          title: '${_formatNumber(data.global.totalStepsToday)} ${t('steps', '歩')}',
          subtitle: t('Global Steps Today', '今日の世界歩数'),
          centerLabel: _formatNumber(data.user.todaySteps),
          centerSuffix: t('steps', '歩'),
          bottomLabel: t(
            'You helped Earth today',
            'あなたは今日、地球に貢献しました',
          ),
          progress: data.todaySummary.goalProgress,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: t('CO₂ Saved', 'CO₂削減量'),
                value:
                    '${data.todaySummary.totalCo2KgSaved.toStringAsFixed(2)} kg',
                icon: Icons.eco_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: t('Prime Points', 'プライムポイント'),
                value: _formatNumber(data.todaySummary.totalPrimePoints),
                icon: Icons.bolt_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title: t('Monthly Event', '月間イベント'),
          value: data.monthlyEventTitle,
          icon: Icons.emoji_events_outlined,
          subtitle:
              '${data.monthlyEventDescription}\n${t('Ends in', '終了まで')} ${data.eventDaysLeft} ${t('days', '日')}',
        ),
        const SizedBox(height: 12),
        _ProgressCard(
          title: t('Daily Goal', 'デイリー目標'),
          current: data.todaySummary.totalSteps,
          goal: data.todaySummary.goalSteps,
          stepLabel: t('steps', '歩'),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          title: t('Why your steps matter', '歩く意味'),
          body: t(
            'ZERON converts walking into verified participation data for future sponsor rewards, monthly events, and carbon-credit linked initiatives.',
            'ZERONは歩行を検証可能な参加データへ変換し、将来のスポンサー報酬、月間イベント、カーボンクレジット連動施策へ接続します。',
          ),
        ),
      ],
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({
    required this.data,
    required this.t,
  });

  final _HomeDemoState data;
  final String Function(String en, String ja) t;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        _PageHeader(
          title: t('Dashboard', 'ダッシュボード'),
          subtitle: t(
            'Live view of users, steps, CO₂ reduction and momentum.',
            '世界の参加状況、歩数、CO₂削減、成長モメンタムの可視化。',
          ),
        ),
        const SizedBox(height: 18),
        _DashboardHero(data: data, t: t),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: t('Active Walkers', 'アクティブユーザー'),
                value: _formatNumber(data.global.activeUsers),
                icon: Icons.groups_2_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: t('Countries', '参加国数'),
                value: _formatNumber(data.global.activeCountries),
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
                title: t('Monthly Steps', '月間歩数'),
                value: _formatNumber(data.global.totalStepsThisMonth),
                icon: Icons.bar_chart_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: t('CO₂ Saved Total', '総CO₂削減'),
                value: '${_formatNumberDouble(data.global.totalCo2KgSaved)} kg',
                icon: Icons.forest_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: t('Growth Signals', '成長指標'),
          child: Column(
            children: [
              _SignalRow(
                label: t('Active Teams', 'アクティブチーム'),
                value: _formatNumber(data.global.activeTeams),
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: t('Participation Pool', '参加母数'),
                value: '${_formatNumber(data.sponsorReadyUsers)} ${t('users', '人')}',
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: t('Reward Reserve', '報酬準備量'),
                value: '¥${_formatNumber(data.global.rewardPoolYen)}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankPage extends StatefulWidget {
  const _RankPage({
    required this.data,
    required this.t,
  });

  final _HomeDemoState data;
  final String Function(String en, String ja) t;

  @override
  State<_RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<_RankPage> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final labels = [
      widget.t('World', '世界'),
      widget.t('Country', '国'),
      widget.t('City', '都市'),
      widget.t('Team', 'チーム'),
    ];

    final lists = [
      widget.data.worldRank,
      widget.data.countryRank,
      widget.data.cityRank,
      widget.data.teamRank,
    ];

    final userPosition = _segment == 0
        ? widget.data.user.worldRank ?? 0
        : _segment == 1
            ? widget.data.user.countryRank ?? 0
            : _segment == 2
                ? widget.data.user.cityRank ?? 0
                : widget.data.user.teamRank ?? 0;

    final userCaption = _segment == 0
        ? widget.t('World ranking', '世界ランキング')
        : _segment == 1
            ? widget.t(
                '${widget.data.user.countryName} ranking',
                '${widget.data.user.countryName}内ランキング',
              )
            : _segment == 2
                ? widget.t(
                    '${widget.data.user.city} ranking',
                    '${widget.data.user.city}内ランキング',
                  )
                : widget.t('Team ranking', 'チームランキング');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        _PageHeader(
          title: widget.t('Rank', 'ランク'),
          subtitle: widget.t(
            'Compete globally, nationally, locally and by team.',
            '世界・国内・都市・チームで競争し、現在地を可視化します。',
          ),
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
          title: widget.t('Your Ranking', '自分の順位'),
          value: '#$userPosition',
          caption: userCaption,
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
                rank: entry.rank,
                name: entry.name,
                value: _formatNumber(entry.value),
                badge: entry.label,
                highlighted: entry.isCurrentUser,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TeamPage extends StatelessWidget {
  const _TeamPage({
    required this.data,
    required this.t,
  });

  final _HomeDemoState data;
  final String Function(String en, String ja) t;

  @override
  Widget build(BuildContext context) {
    final teams = [
      data.primaryTeam,
      data.friendsTeam,
      data.familyTeam,
      data.companyTeam,
    ];

    final totalMembers = teams.fold<int>(
      0,
      (sum, team) => sum + team.memberCount,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        _PageHeader(
          title: t('Team', 'チーム'),
          subtitle: t(
            'Belong, build, compete and co-create impact.',
            '所属、共創、競争、協力をひとつの参加体験に統合します。',
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: t('Active Teams', 'チーム数'),
                value: _formatNumber(data.global.activeTeams),
                icon: Icons.groups_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: t('Members', 'メンバー数'),
                value: _formatNumber(totalMembers),
                icon: Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(
          teams.length,
          (index) {
            final team = teams[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == teams.length - 1 ? 0 : 12),
              child: _TeamCard(
                team: team,
                isPrimary: team.id == data.primaryTeam.id,
                t: t,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _CreateTeamCard(t: t),
      ],
    );
  }
}

class _AccountPage extends StatelessWidget {
  const _AccountPage({
    required this.data,
    required this.t,
    required this.language,
    required this.soundOn,
    required this.notificationsOn,
    required this.onSetLanguage,
    required this.onSetSound,
    required this.onSetNotifications,
  });

  final _HomeDemoState data;
  final String Function(String en, String ja) t;
  final String language;
  final bool soundOn;
  final bool notificationsOn;
  final Future<void> Function(String value) onSetLanguage;
  final Future<void> Function(bool value) onSetSound;
  final Future<void> Function(bool value) onSetNotifications;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        _PageHeader(
          title: t('Account', 'アカウント'),
          subtitle: t(
            'Identity, permissions, legal status and membership.',
            'プロフィール、法務、設定、サブスクリプション管理。',
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: t('Profile', 'プロフィール'),
          child: Column(
            children: [
              _AccountRow(label: 'Email', value: data.user.email),
              const SizedBox(height: 14),
              _AccountRow(
                label: t('Country', '国'),
                value: data.user.countryName,
              ),
              const SizedBox(height: 14),
              _AccountRow(
                label: t('City', '都市'),
                value: data.user.city,
              ),
              const SizedBox(height: 14),
              _AccountRow(
                label: t('Plan', 'プラン'),
                value: _planLabel(data.user.plan),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: t('Subscription', 'サブスクリプション'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(
                  'Unlock advanced ranking analytics, event boosts, sponsor campaign priority and future reward acceleration.',
                  '高度なランキング分析、イベントブースト、スポンサーキャンペーン優先参加、将来の報酬加速を解放します。',
                ),
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
                    Expanded(
                      child: Text(
                        t(
                          'Subscription ready for sponsor and reward expansion',
                          'スポンサー連動と報酬拡張に対応するサブスク準備済み',
                        ),
                        style: const TextStyle(
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
          title: t('Legal', '法務'),
          child: Column(
            children: [
              _SimpleArrowRow(label: t('Terms of Service', '利用規約')),
              const SizedBox(height: 14),
              _SimpleArrowRow(label: t('Privacy Policy', 'プライバシーポリシー')),
              const SizedBox(height: 14),
              _SimpleArrowRow(label: t('Anti-Cheat Policy', '不正防止ポリシー')),
              const SizedBox(height: 14),
              _SimpleArrowRow(label: t('Commercial Law', '特定商取引法表記')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: t('Settings', '設定'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('Language', '言語'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _LanguageSelector(
                selected: language,
                onChanged: onSetLanguage,
              ),
              const SizedBox(height: 18),
              _ToggleRow(
                label: t('Sound', '音'),
                value: soundOn,
                onChanged: onSetSound,
              ),
              const SizedBox(height: 12),
              _ToggleRow(
                label: t('Notifications', '通知'),
                value: notificationsOn,
                onChanged: onSetNotifications,
              ),
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
    required this.centerSuffix,
    required this.bottomLabel,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final String centerLabel;
  final String centerSuffix;
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
                      centerSuffix,
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
  const _DashboardHero({
    required this.data,
    required this.t,
  });

  final _HomeDemoState data;
  final String Function(String en, String ja) t;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('Global Field', 'グローバルフィールド'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_formatNumber(data.global.totalStepsToday)} ${t('steps', '歩')}',
            style: const TextStyle(
              color: Color(0xFFEAFBF2),
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          _MetricLine(
            label: t('CO₂ Saved Today', '今日のCO₂削減'),
            value: '${_formatNumberDouble(data.global.totalCo2KgSaved)} kg',
          ),
          const SizedBox(height: 10),
          _MetricLine(
            label: t('Reward Points Minted', '生成ポイント'),
            value: _formatNumber(data.global.totalPrimePoints),
          ),
          const SizedBox(height: 10),
          _MetricLine(
            label: t('Active Cities', 'アクティブ都市数'),
            value: _formatNumber(data.global.activeCities),
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
    required this.stepLabel,
  });

  final String title;
  final int current;
  final int goal;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    final progress = goal <= 0 ? 0.0 : (current / goal).clamp(0.0, 1.0);

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
                ' / ${_formatNumber(goal)} $stepLabel',
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
      decoration: _panelDecoration(highlighted: highlighted),
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

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.team,
    required this.isPrimary,
    required this.t,
  });

  final TeamModel team;
  final bool isPrimary;
  final String Function(String en, String ja) t;

  String _kindLabel() {
    switch (team.kind) {
      case TeamKind.friends:
        return t('Friends', 'フレンズ');
      case TeamKind.family:
        return t('Family', 'ファミリー');
      case TeamKind.company:
        return t('Company', 'カンパニー');
    }
  }

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8FFE3).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFB8FFE3).withOpacity(0.18),
                  ),
                ),
                child: Text(
                  _kindLabel(),
                  style: const TextStyle(
                    color: Color(0xFFEFFFF8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                isPrimary ? t('Primary', 'メイン') : t('Active', '稼働中'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            team.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            team.description ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TinyMetric(
                  label: t('Members', '人数'),
                  value: _formatNumber(team.memberCount),
                ),
              ),
              Expanded(
                child: _TinyMetric(
                  label: t('CO₂ Saved', 'CO₂削減'),
                  value: '${team.totalCo2KgSaved.toStringAsFixed(1)} kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _TinyMetric(
                  label: t('Points', 'ポイント'),
                  value: _formatNumber(team.totalPrimePoints),
                ),
              ),
              Expanded(
                child: _TinyMetric(
                  label: t('Steps', '歩数'),
                  value: _formatNumber(team.totalSteps),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateTeamCard extends StatelessWidget {
  const _CreateTeamCard({
    required this.t,
  });

  final String Function(String en, String ja) t;

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
              color: const Color(0xFFB8FFE3).withOpacity(0.10),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Color(0xFFB8FFE3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Create Team', 'チームを作成'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t(
                    'Build a new participation unit for friends, family or company.',
                    'フレンド、ファミリー、会社単位で新しい参加ユニットを作成します。',
                  ),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.64),
                    fontSize: 12.5,
                    height: 1.45,
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

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
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

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final Future<void> Function(String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LanguageButton(
            label: 'English',
            selected: selected == 'en',
            onTap: () => onChanged('en'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LanguageButton(
            label: '日本語',
            selected: selected == 'ja',
            onTap: () => onChanged('ja'),
          ),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFB8FFE3).withOpacity(0.12)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFFB8FFE3).withOpacity(0.22)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected
                ? const Color(0xFFEFFFF8)
                : Colors.white.withOpacity(0.65),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final Future<void> Function(bool value) onChanged;

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
        Switch.adaptive(
          value: value,
          activeColor: const Color(0xFFB8FFE3),
          onChanged: (next) async {
            await onChanged(next);
          },
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.labelBuilder,
    required this.onChanged,
  });

  final int index;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_BottomBarItem>[
      const _BottomBarItem(Icons.home_filled),
      const _BottomBarItem(Icons.public),
      const _BottomBarItem(Icons.bar_chart_rounded),
      const _BottomBarItem(Icons.groups),
      const _BottomBarItem(Icons.person_rounded),
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
                          labelBuilder(i),
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
  const _BottomBarItem(this.icon);

  final IconData icon;
}

class _HomeDemoState {
  const _HomeDemoState({
    required this.user,
    required this.todaySummary,
    required this.global,
    required this.primaryTeam,
    required this.friendsTeam,
    required this.familyTeam,
    required this.companyTeam,
    required this.worldRank,
    required this.countryRank,
    required this.cityRank,
    required this.teamRank,
    required this.monthlyEventTitle,
    required this.monthlyEventDescription,
    required this.eventDaysLeft,
    required this.sponsorReadyUsers,
  });

  final ZeronUser user;
  final DailyImpactSummary todaySummary;
  final GlobalImpactSnapshot global;
  final TeamModel primaryTeam;
  final TeamModel friendsTeam;
  final TeamModel familyTeam;
  final TeamModel companyTeam;
  final List<RankEntryModel> worldRank;
  final List<RankEntryModel> countryRank;
  final List<RankEntryModel> cityRank;
  final List<RankEntryModel> teamRank;
  final String monthlyEventTitle;
  final String monthlyEventDescription;
  final int eventDaysLeft;
  final int sponsorReadyUsers;
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

    final earthRect = Rect.fromCircle(center: center, radius: radius);

    final earth = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.18, -0.22),
        radius: 0.96,
        colors: [
          const Color(0xFF5BE1D4).withOpacity(0.92),
          const Color(0xFF12415A).withOpacity(0.96),
          const Color(0xFF051017),
        ],
        stops: const [0.0, 0.38, 1.0],
      ).createShader(earthRect);

    canvas.drawCircle(center, radius, earth);

    final continent = Paint()
      ..color = const Color(0xFF9EF6D6).withOpacity(0.24)
      ..style = PaintingStyle.fill;

    final continent2 = Paint()
      ..color = const Color(0xFFC8FFE6).withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final asia = Path()
      ..moveTo(center.dx - radius * 0.05, center.dy - radius * 0.28)
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy - radius * 0.36,
        center.dx + radius * 0.24,
        center.dy - radius * 0.16,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.32,
        center.dy - radius * 0.02,
        center.dx + radius * 0.12,
        center.dy + radius * 0.12,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.06,
        center.dy + radius * 0.02,
        center.dx - radius * 0.05,
        center.dy - radius * 0.28,
      );

    final australia = Path()
      ..moveTo(center.dx + radius * 0.18, center.dy + radius * 0.24)
      ..quadraticBezierTo(
        center.dx + radius * 0.30,
        center.dy + radius * 0.20,
        center.dx + radius * 0.28,
        center.dy + radius * 0.34,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy + radius * 0.38,
        center.dx + radius * 0.14,
        center.dy + radius * 0.28,
      )
      ..close();

    final eurasia = Path()
      ..moveTo(center.dx - radius * 0.32, center.dy - radius * 0.08)
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy - radius * 0.24,
        center.dx - radius * 0.02,
        center.dy - radius * 0.16,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy - radius * 0.02,
        center.dx - radius * 0.30,
        center.dy + radius * 0.04,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.36,
        center.dy - radius * 0.02,
        center.dx - radius * 0.32,
        center.dy - radius * 0.08,
      );

    canvas.save();
    canvas.clipPath(Path()..addOval(earthRect));
    canvas.drawPath(asia, continent);
    canvas.drawPath(australia, continent2);
    canvas.drawPath(eurasia, continent2);

    final cloud = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = Colors.white.withOpacity(0.05);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.92),
      -0.8,
      1.6,
      false,
      cloud..style = PaintingStyle.stroke..strokeWidth = radius * 0.08,
    );
    canvas.restore();

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

String _planLabel(ZeronPlan plan) {
  switch (plan) {
    case ZeronPlan.free:
      return 'Free';
    case ZeronPlan.plus:
      return 'ZERON+';
    case ZeronPlan.sponsor:
      return 'Sponsor';
  }
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

String _formatNumberDouble(double value) {
  return _formatNumber(value.round());
}