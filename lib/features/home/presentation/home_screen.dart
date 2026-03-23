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

  static const String _profileCompletedKey = 'zeron_profile_completed_v1';
  static const String _usernameKey = 'zeron_username_v1';
  static const String _emailKey = 'zeron_email_v1';
  static const String _countryKey = 'zeron_country_v1';
  static const String _regionKey = 'zeron_region_v1';

  late final AnimationController _openingController;

  bool _showOpening = true;
  bool _isEntering = false;
  bool _profileCompleted = false;

  String _username = '';
  String _email = '';
  String _country = '';
  String _region = '';

  @override
  void initState() {
    super.initState();

    _openingController = AnimationController(
      vsync: this,
      duration: _openingDuration,
    )..forward();

    _loadOpeningState();
  }

  @override
  void dispose() {
    _openingController.dispose();
    super.dispose();
  }

  Future<void> _loadOpeningState() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _profileCompleted = prefs.getBool(_profileCompletedKey) ?? false;
      _username = prefs.getString(_usernameKey) ?? '';
      _email = prefs.getString(_emailKey) ?? '';
      _country = prefs.getString(_countryKey) ?? '';
      _region = prefs.getString(_regionKey) ?? '';
    });
  }

  Future<void> _persistProfile({
    required String username,
    required String email,
    required String country,
    required String region,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileCompletedKey, true);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_countryKey, country);
    await prefs.setString(_regionKey, region);

    if (!mounted) return;
    setState(() {
      _profileCompleted = true;
      _username = username;
      _email = email;
      _country = country;
      _region = region;
    });
  }

  Future<void> _finishOpening() async {
    if (!mounted || !_showOpening || _isEntering) return;

    _isEntering = true;

    setState(() {
      _showOpening = false;
    });

    _isEntering = false;
  }

  Future<void> _handleOpeningTap() async {
    if (_isEntering) return;

    if (!_profileCompleted) {
      final result = await showDialog<_RegistrationResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _RegistrationDialog(
          initialUsername: _username,
          initialEmail: _email,
          initialCountry: _country,
          initialRegion: _region,
        ),
      );

      if (result == null) return;

      await _persistProfile(
        username: result.username,
        email: result.email,
        country: result.country,
        region: result.region,
      );
    }

    await _finishOpening();
  }

  Future<void> _openSettingsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF091015),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _OpeningSettingsSheet(
          username: _username,
          email: _email,
          country: _country,
          region: _region,
          onOpenAccountInfo: () async {
            Navigator.of(context).pop();
            await showDialog<void>(
              context: this.context,
              builder: (_) => _InfoDocumentDialog(
                title: 'Account Information',
                content: _buildAccountInfoText(),
              ),
            );
          },
          onOpenCommercialLaw: () async {
            Navigator.of(context).pop();
            await showDialog<void>(
              context: this.context,
              builder: (_) => const _InfoDocumentDialog(
                title: 'Specified Commercial Transaction Act',
                content: _commercialLawText,
              ),
            );
          },
          onOpenTerms: () async {
            Navigator.of(context).pop();
            await showDialog<void>(
              context: this.context,
              builder: (_) => const _InfoDocumentDialog(
                title: 'Terms of Service',
                content: _termsText,
              ),
            );
          },
          onOpenPrivacy: () async {
            Navigator.of(context).pop();
            await showDialog<void>(
              context: this.context,
              builder: (_) => const _InfoDocumentDialog(
                title: 'Privacy Policy',
                content: _privacyText,
              ),
            );
          },
        );
      },
    );
  }

  String _buildAccountInfoText() {
    return '''
Username
${_username.isEmpty ? 'Not registered' : _username}

Email
${_email.isEmpty ? 'Not registered' : _email}

Country
${_country.isEmpty ? 'Not registered' : _country}

Region
${_region.isEmpty ? 'Not registered' : _region}
''';
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
                onPrimaryTap: _handleOpeningTap,
                onOpenSettings: _openSettingsSheet,
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
    required this.onPrimaryTap,
    required this.onOpenSettings,
  });

  final AnimationController controller;
  final Future<void> Function() onPrimaryTap;
  final Future<void> Function() onOpenSettings;

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
        final double infoOpacity =
            Curves.easeOutCubic.transform(((t - 0.44) / 0.24).clamp(0.0, 1.0));
        final double footerOpacity =
            Curves.easeOutCubic.transform(((t - 0.62) / 0.20).clamp(0.0, 1.0));
        final double drift = math.sin(presenceSeconds * 0.55) * 8.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            await onPrimaryTap();
          },
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
                        const Spacer(),
                        Opacity(
                          opacity: infoOpacity,
                          child: const Column(
                            children: [
                              Text(
                                'Version 1.0.0',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                              const SizedBox(height: 26),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  await onOpenSettings();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Setting / 設定',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.92),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
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

class _RegistrationResult {
  const _RegistrationResult({
    required this.username,
    required this.email,
    required this.country,
    required this.region,
  });

  final String username;
  final String email;
  final String country;
  final String region;
}

class _RegistrationDialog extends StatefulWidget {
  const _RegistrationDialog({
    required this.initialUsername,
    required this.initialEmail,
    required this.initialCountry,
    required this.initialRegion,
  });

  final String initialUsername;
  final String initialEmail;
  final String initialCountry;
  final String initialRegion;

  @override
  State<_RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<_RegistrationDialog> {
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _countryController;
  late final TextEditingController _regionController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _emailController = TextEditingController(text: widget.initialEmail);
    _countryController = TextEditingController(text: widget.initialCountry);
    _regionController = TextEditingController(text: widget.initialRegion);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _submit() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final country = _countryController.text.trim();
    final region = _regionController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        country.isEmpty ||
        region.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    Navigator.of(context).pop(
      _RegistrationResult(
        username: username,
        email: email,
        country: country,
        region: region,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF091015),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create your account / アカウント作成',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Set your identity for ranking, regional participation, and future rewards.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              _FormField(
                controller: _usernameController,
                label: 'Username',
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _emailController,
                label: 'Email address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _countryController,
                label: 'Country',
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _regionController,
                label: 'Region',
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
                  onPressed: _submit,
                  child: const Text(
                    'Continue',
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
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.60)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFFB8FFE3).withOpacity(0.24),
          ),
        ),
      ),
    );
  }
}

class _OpeningSettingsSheet extends StatelessWidget {
  const _OpeningSettingsSheet({
    required this.username,
    required this.email,
    required this.country,
    required this.region,
    required this.onOpenAccountInfo,
    required this.onOpenCommercialLaw,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final String username;
  final String email;
  final String country;
  final String region;
  final Future<void> Function() onOpenAccountInfo;
  final Future<void> Function() onOpenCommercialLaw;
  final Future<void> Function() onOpenTerms;
  final Future<void> Function() onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Setting',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            _SettingsRow(
              label: 'Account information',
              value: username.isEmpty ? 'Not registered' : username,
              onTap: onOpenAccountInfo,
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              label: 'Specified Commercial Transaction Act',
              onTap: onOpenCommercialLaw,
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              label: 'Terms of Service',
              onTap: onOpenTerms,
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              label: 'Privacy Policy',
              onTap: onOpenPrivacy,
            ),
            const SizedBox(height: 10),
            if (email.isNotEmpty || country.isNotEmpty || region.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Text(
                  [
                    if (email.isNotEmpty) email,
                    if (country.isNotEmpty) country,
                    if (region.isNotEmpty) region,
                  ].join(' · '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.onTap,
    this.value,
  });

  final String label;
  final String? value;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      value!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.58),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.60),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoDocumentDialog extends StatelessWidget {
  const _InfoDocumentDialog({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF091015),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.74),
                      fontSize: 13,
                      height: 1.65,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.08),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
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
      ),
    );
  }
}

const String _commercialLawText = '''
Seller
ZERON TOKYO

Representative
Hiroyuki Sugiura

Contact Email
support@zeron.tokyo

Service Price
Displayed on each purchase or subscription page.

Additional Fees
Internet connection fees and communication charges are borne by the user.

Payment Timing
Charged at the time of subscription or purchase confirmation.

Service Delivery Timing
Access is granted immediately after payment confirmation unless otherwise stated.

Cancellation
Users may cancel recurring subscriptions from the platform settings before the next billing date.

Refund Policy
Due to the nature of digital services, completed payments are generally non-refundable unless required by applicable law.

Operating Environment
A supported smartphone, operating system, and internet connection are required.
''';

const String _termsText = '''
These Terms of Service govern access to ZERON and related participation features.

1. Users may create an account and participate in walking-based environmental initiatives.
2. Users must provide accurate registration information.
3. Fraudulent step activity, identity abuse, or system exploitation may result in suspension.
4. Future rewards, campaigns, and sponsor programs may have additional rules.
5. ZERON may update features, policies, and service details to improve platform operations.
6. Continued use of the service constitutes agreement to the latest terms.
''';

const String _privacyText = '''
ZERON collects limited account and participation data to operate rankings, community participation, and future environmental reward features.

Collected Information
- Username
- Email address
- Country
- Region
- Walking participation data
- Device and app usage data required for service stability

Purpose of Use
- Account creation and management
- Ranking and regional participation features
- Fraud prevention
- Service improvement
- Future campaign and reward operations

Data Sharing
ZERON does not sell personal information. Data may be shared only when required by law or when necessary to provide the service through trusted infrastructure partners.

User Rights
Users may request correction or deletion of stored personal information subject to applicable law and operational requirements.
''';

const String _antiCheatText = '''
ZERON uses participation integrity rules to protect rankings, sponsor-linked rewards, and environmental credibility.

Prohibited Conduct
- Artificial step inflation using spoofing, automation, emulator-based motion, or unauthorized devices
- Multiple account abuse for ranking manipulation
- Tampering with app behavior, APIs, local storage, or measurement logic
- Any fraudulent participation designed to distort rankings, campaigns, or rewards

Enforcement
ZERON may investigate suspicious activity and take action including score invalidation, account restriction, suspension, or permanent removal.

Data Review
Participation records, device metadata, behavioral patterns, and anomaly signals may be reviewed to protect fairness.

Appeals
Users may contact support for a review if they believe an enforcement action was applied incorrectly.
''';

class _ZeronMainShell extends StatefulWidget {
  const _ZeronMainShell({super.key});

  @override
  State<_ZeronMainShell> createState() => _ZeronMainShellState();
}

class _ZeronMainShellState extends State<_ZeronMainShell> {
  static const String _languageKey = 'zeron_language_v1';
  static const String _soundKey = 'zeron_sound_v1';
  static const String _notificationsKey = 'zeron_notifications_v1';

  static const String _profileNameKey = 'zeron_username_v1';
  static const String _profileEmailKey = 'zeron_email_v1';
  static const String _profileCountryKey = 'zeron_country_v1';
  static const String _profileRegionKey = 'zeron_region_v1';

  static const String _persistTotalStepsKey = 'zeron_total_steps_v2';
  static const String _persistTotalCo2Key = 'zeron_total_co2_v2';
  static const String _persistTotalPointsKey = 'zeron_total_points_v2';
  static const String _persistLastDateKey = 'zeron_last_date_v2';
  static const String _persistTeamsKey = 'zeron_teams_v2';
  static const String _persistPrimaryTeamIdKey = 'zeron_primary_team_id_v2';

  int _currentIndex = 0;
  String _language = 'en';
  bool _soundOn = true;
  bool _notificationsOn = true;

  late ZeronUser _user;
  late DailyImpactSummary _todaySummary;
  late GlobalImpactSnapshot _global;
  late TeamModel _primaryTeam;
  late TeamModel _friendsTeam;
  late TeamModel _coreTeam;
  late TeamModel _companyTeam;
  late List<RankEntryModel> _worldRank;
  late List<RankEntryModel> _countryRank;
  late List<RankEntryModel> _cityRank;
  late List<RankEntryModel> _teamRank;
  late String _monthlyEventTitle;
  late String _monthlyEventDescription;
  late int _eventDaysLeft;
  late int _sponsorReadyUsers;

  final List<TeamModel> _teams = <TeamModel>[];

  StreamSubscription<int>? _stepSubscription;
  Timer? _ambientTimer;

  double _presenceSeconds = 0.0;
  double _interactionEnergy = 0.10;
  bool _isPointerInside = false;
  Offset _pointerPosition = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _startAmbientTimer();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _ambientTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await StepService.init();
    await _loadSettings();
    await _loadRuntimeState();
    _bindStepStream();
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

  Future<void> _loadRuntimeState() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    final displayName = prefs.getString(_profileNameKey);
    final email = prefs.getString(_profileEmailKey) ?? '';
    final country = prefs.getString(_profileCountryKey) ?? 'Japan';
    final region = prefs.getString(_profileRegionKey) ?? 'Tokyo';

    final persistedDate = prefs.getString(_persistLastDateKey);
    final persistedTotalSteps = prefs.getInt(_persistTotalStepsKey) ?? 0;
    final persistedTotalCo2 = prefs.getDouble(_persistTotalCo2Key) ?? 0.0;
    final persistedTotalPoints = prefs.getInt(_persistTotalPointsKey) ?? 0;

    final liveTodaySteps = StepService.currentSteps;
    final liveSummary = StepService.buildSummary(liveTodaySteps);

    final totalSteps = persistedDate == todayKey
        ? (persistedTotalSteps - liveTodaySteps).clamp(0, 1 << 30) + liveTodaySteps
        : persistedTotalSteps;

    final totalCo2 = persistedDate == todayKey
        ? (persistedTotalCo2 - liveSummary.totalCo2KgSaved).clamp(0.0, double.infinity) +
            liveSummary.totalCo2KgSaved
        : persistedTotalCo2;

    final totalPoints = persistedDate == todayKey
        ? (persistedTotalPoints - liveSummary.totalPrimePoints).clamp(0, 1 << 30) +
            liveSummary.totalPrimePoints
        : persistedTotalPoints;

    _todaySummary = liveSummary;

    _user = ZeronUser(
      id: 'zeron_local_user',
      email: email,
      countryCode: 'JP',
      countryName: country.isEmpty ? 'Japan' : country,
      city: region.isEmpty ? 'Tokyo' : region,
      plan: ZeronPlan.free,
      termsAccepted: true,
      createdAt: now,
      updatedAt: now,
      lastActiveAt: now,
      displayName: (displayName == null || displayName.trim().isEmpty)
          ? 'ZERON User'
          : displayName.trim(),
      primaryTeamId: null,
      totalSteps: totalSteps,
      totalCo2KgSaved: totalCo2,
      totalPrimePoints: totalPoints,
      todaySteps: liveSummary.totalSteps,
      todayCo2KgSaved: liveSummary.totalCo2KgSaved,
      todayPrimePoints: liveSummary.totalPrimePoints,
      worldRank: 1,
      countryRank: 1,
      cityRank: 1,
      teamRank: 1,
    );

    _teams
      ..clear()
      ..addAll(_loadTeamsFromPrefs(prefs, now));

    if (_teams.isEmpty) {
      _teams.add(
        TeamModel(
          id: 'team_${now.microsecondsSinceEpoch}',
          name: 'My Team',
          kind: TeamKind.team,
          ownerUserId: _user.id,
          memberCount: 1,
          totalSteps: _user.totalSteps,
          totalCo2KgSaved: _user.totalCo2KgSaved,
          totalPrimePoints: _user.totalPrimePoints,
          createdAt: now,
          updatedAt: now,
          description: 'Your primary local impact team.',
          countryCode: _user.countryCode,
          city: _user.city,
        ),
      );
      await _saveTeams();
    }

    final storedPrimaryId = prefs.getString(_persistPrimaryTeamIdKey);
    _primaryTeam = _teams.firstWhere(
      (team) => team.id == storedPrimaryId,
      orElse: () => _teams.first,
    );

    _friendsTeam = _firstTeamOfKind(TeamKind.friends) ?? _primaryTeam;
    _coreTeam = _firstTeamOfKind(TeamKind.team) ?? _primaryTeam;
    _companyTeam = _firstTeamOfKind(TeamKind.company) ?? _primaryTeam;

    _monthlyEventTitle = 'Daily Earth Impact';
    _monthlyEventDescription =
        'Your live step data is measured on-device and converted to visible impact in real time.';
    _eventDaysLeft = 0;
    _sponsorReadyUsers = 1;

    _rebuildComputedState();
  }

  TeamModel? _firstTeamOfKind(TeamKind kind) {
    for (final team in _teams) {
      if (team.kind == kind) return team;
    }
    return null;
  }

  List<TeamModel> _loadTeamsFromPrefs(SharedPreferences prefs, DateTime now) {
    final raw = prefs.getStringList(_persistTeamsKey) ?? <String>[];
    return raw
        .map((item) {
          final parts = item.split('|||');
          if (parts.length < 9) return null;

          final kind = switch (parts[2]) {
            'friends' => TeamKind.friends,
            'team' => TeamKind.team,
            _ => TeamKind.company,
          };

          return TeamModel(
            id: parts[0],
            name: parts[1],
            kind: kind,
            ownerUserId: _user.id,
            memberCount: int.tryParse(parts[3]) ?? 1,
            totalSteps: int.tryParse(parts[4]) ?? 0,
            totalCo2KgSaved: double.tryParse(parts[5]) ?? 0.0,
            totalPrimePoints: int.tryParse(parts[6]) ?? 0,
            createdAt: DateTime.tryParse(parts[7]) ?? now,
            updatedAt: DateTime.tryParse(parts[8]) ?? now,
            description: parts.length > 9 ? parts[9] : null,
            countryCode: _user.countryCode,
            city: _user.city,
          );
        })
        .whereType<TeamModel>()
        .toList();
  }

  Future<void> _saveTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _teams
        .map(
          (team) => [
            team.id,
            team.name,
            switch (team.kind) {
              TeamKind.friends => 'friends',
              TeamKind.team => 'team',
              TeamKind.company => 'company',
            },
            '${team.memberCount}',
            '${team.totalSteps}',
            '${team.totalCo2KgSaved}',
            '${team.totalPrimePoints}',
            team.createdAt.toIso8601String(),
            team.updatedAt.toIso8601String(),
            team.description ?? '',
          ].join('|||'),
        )
        .toList();

    await prefs.setStringList(_persistTeamsKey, payload);
    await prefs.setString(_persistPrimaryTeamIdKey, _primaryTeam.id);
  }

  void _bindStepStream() {
    _stepSubscription?.cancel();
    _stepSubscription = StepService.stepStream.listen((steps) async {
      if (!mounted) return;

      final summary = StepService.buildSummary(steps);
      final todayKey = _dateKey(DateTime.now());

      final previousTodaySteps = _user.todaySteps;
      final previousTodayCo2 = _user.todayCo2KgSaved;
      final previousTodayPoints = _user.todayPrimePoints;

      final totalSteps =
          (_user.totalSteps - previousTodaySteps).clamp(0, 1 << 30) + summary.totalSteps;
      final totalCo2 =
          (_user.totalCo2KgSaved - previousTodayCo2).clamp(0.0, double.infinity) +
              summary.totalCo2KgSaved;
      final totalPoints =
          (_user.totalPrimePoints - previousTodayPoints).clamp(0, 1 << 30) +
              summary.totalPrimePoints;

      final updatedUser = _user.copyWith(
        todaySteps: summary.totalSteps,
        todayCo2KgSaved: summary.totalCo2KgSaved,
        todayPrimePoints: summary.totalPrimePoints,
        totalSteps: totalSteps,
        totalCo2KgSaved: totalCo2,
        totalPrimePoints: totalPoints,
        updatedAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        worldRank: 1,
        countryRank: 1,
        cityRank: 1,
        teamRank: 1,
      );

      _user = updatedUser;
      _todaySummary = summary;
      _syncTeamsWithUser();
      _rebuildComputedState();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_persistTotalStepsKey, updatedUser.totalSteps);
      await prefs.setDouble(_persistTotalCo2Key, updatedUser.totalCo2KgSaved);
      await prefs.setInt(_persistTotalPointsKey, updatedUser.totalPrimePoints);
      await prefs.setString(_persistLastDateKey, todayKey);
      await _saveTeams();

      if (!mounted) return;
      setState(() {});
    });
  }

  void _syncTeamsWithUser() {
    for (int i = 0; i < _teams.length; i++) {
      final team = _teams[i];
      if (team.id == _primaryTeam.id) {
        _teams[i] = TeamModel(
          id: team.id,
          name: team.name,
          kind: team.kind,
          ownerUserId: team.ownerUserId,
          memberCount: team.memberCount,
          totalSteps: _user.totalSteps,
          totalCo2KgSaved: _user.totalCo2KgSaved,
          totalPrimePoints: _user.totalPrimePoints,
          createdAt: team.createdAt,
          updatedAt: DateTime.now(),
          description: team.description,
          countryCode: team.countryCode,
          city: team.city,
        );
        _primaryTeam = _teams[i];
        break;
      }
    }

    _friendsTeam = _firstTeamOfKind(TeamKind.friends) ?? _primaryTeam;
    _coreTeam = _firstTeamOfKind(TeamKind.team) ?? _primaryTeam;
    _companyTeam = _firstTeamOfKind(TeamKind.company) ?? _primaryTeam;
  }

  void _rebuildComputedState() {
    final activeTeams = _teams.length;
    final totalTeamSteps = _teams.fold<int>(0, (sum, team) => sum + team.totalSteps);
    final totalTeamPoints =
        _teams.fold<int>(0, (sum, team) => sum + team.totalPrimePoints);
    final totalTeamCo2 =
        _teams.fold<double>(0.0, (sum, team) => sum + team.totalCo2KgSaved);
    final totalMembers = _teams.fold<int>(0, (sum, team) => sum + team.memberCount);

    _global = GlobalImpactSnapshot(
      activeUsers: 1,
      activeTeams: activeTeams,
      activeCountries: 1,
      activeCities: 1,
      totalStepsToday: _user.todaySteps,
      totalStepsThisMonth: _user.totalSteps,
      totalCo2KgSaved: _user.totalCo2KgSaved,
      totalPrimePoints: _user.totalPrimePoints,
      rewardPoolYen: _user.totalPrimePoints,
      updatedAt: DateTime.now(),
    );

    final int todayCo2Grams = (_user.todayCo2KgSaved * 1000).round();

    _worldRank = <RankEntryModel>[
      RankEntryModel(
        id: 'world_you',
        scope: RankScope.world,
        rank: 1,
        name: _user.displayName ?? 'You',
        value: todayCo2Grams,
        label: '${_user.todayCo2KgSaved.toStringAsFixed(2)} kg CO₂ · ${_formatNumber(_user.todaySteps)} steps',
        isCurrentUser: true,
        relatedUserId: _user.id,
      ),
    ];

    _countryRank = <RankEntryModel>[
      RankEntryModel(
        id: 'country_you',
        scope: RankScope.country,
        rank: 1,
        name: _user.displayName ?? 'You',
        value: todayCo2Grams,
        label: '${_user.countryName} · ${_user.todayCo2KgSaved.toStringAsFixed(2)} kg CO₂ · ${_formatNumber(_user.todaySteps)} steps',
        isCurrentUser: true,
        relatedUserId: _user.id,
      ),
    ];

    _cityRank = <RankEntryModel>[
      RankEntryModel(
        id: 'city_you',
        scope: RankScope.city,
        rank: 1,
        name: _user.displayName ?? 'You',
        value: todayCo2Grams,
        label: '${_user.city} · ${_user.todayCo2KgSaved.toStringAsFixed(2)} kg CO₂ · ${_formatNumber(_user.todaySteps)} steps',
        isCurrentUser: true,
        relatedUserId: _user.id,
      ),
    ];

    final sortedTeams = [..._teams]
      ..sort((a, b) => b.totalCo2KgSaved.compareTo(a.totalCo2KgSaved));

    _teamRank = List<RankEntryModel>.generate(
      sortedTeams.length,
      (index) {
        final team = sortedTeams[index];
        return RankEntryModel(
          id: 'team_${team.id}',
          scope: RankScope.team,
          rank: index + 1,
          name: team.name,
          value: (team.totalCo2KgSaved * 1000).round(),
          label:
              '${team.totalCo2KgSaved.toStringAsFixed(2)} kg CO₂ · ${_formatNumber(team.totalSteps)} steps',
          isCurrentUser: team.id == _primaryTeam.id,
          relatedTeamId: team.id,
        );
      },
    );
    _sponsorReadyUsers = 1;
    _monthlyEventTitle = activeTeams > 1 ? 'Team Impact Live' : 'Solo Impact Live';
    _monthlyEventDescription =
        'Device steps, saved teams, points, and CO₂ are running from local live data.';
    _eventDaysLeft = 0;

    _global = GlobalImpactSnapshot(
      activeUsers: 1,
      activeTeams: activeTeams,
      activeCountries: 1,
      activeCities: 1,
      totalStepsToday: _user.todaySteps,
      totalStepsThisMonth: totalTeamSteps == 0 ? _user.totalSteps : totalTeamSteps,
      totalCo2KgSaved: totalTeamCo2 == 0 ? _user.totalCo2KgSaved : totalTeamCo2,
      totalPrimePoints: totalTeamPoints == 0 ? _user.totalPrimePoints : totalTeamPoints,
      rewardPoolYen: totalMembers * 100,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _createTeam(_TeamDraft draft) async {
    final now = DateTime.now();
    final newTeam = TeamModel(
      id: 'team_${now.microsecondsSinceEpoch}',
      name: draft.name,
      kind: draft.kind,
      ownerUserId: _user.id,
      memberCount: 1,
      totalSteps: draft.makePrimary ? _user.totalSteps : 0,
      totalCo2KgSaved: draft.makePrimary ? _user.totalCo2KgSaved : 0,
      totalPrimePoints: draft.makePrimary ? _user.totalPrimePoints : 0,
      createdAt: now,
      updatedAt: now,
      description: draft.description,
      countryCode: _user.countryCode,
      city: _user.city,
    );

    _teams.add(newTeam);

    if (draft.makePrimary || _teams.length == 1) {
      _primaryTeam = newTeam;
      _syncTeamsWithUser();
    }

    _friendsTeam = _firstTeamOfKind(TeamKind.friends) ?? _primaryTeam;
    _coreTeam = _firstTeamOfKind(TeamKind.team) ?? _primaryTeam;
    _companyTeam = _firstTeamOfKind(TeamKind.company) ?? _primaryTeam;

    _rebuildComputedState();
    await _saveTeams();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openTermsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _InfoDocumentDialog(
        title: 'Terms of Service',
        content: _termsText,
      ),
    );
  }

  Future<void> _openPrivacyDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _InfoDocumentDialog(
        title: 'Privacy Policy',
        content: _privacyText,
      ),
    );
  }

  Future<void> _openCommercialLawDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _InfoDocumentDialog(
        title: 'Specified Commercial Transaction Act',
        content: _commercialLawText,
      ),
    );
  }

  Future<void> _openAntiCheatDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _InfoDocumentDialog(
        title: 'Anti-Cheat Policy',
        content: _antiCheatText,
      ),
    );
  }

  String _dateKey(DateTime value) {
    return '${value.year}${value.month.toString().padLeft(2, '0')}${value.day.toString().padLeft(2, '0')}';
  }

  _HomeDemoState _viewState() {
    return _HomeDemoState(
      user: _user,
      todaySummary: _todaySummary,
      global: _global,
      primaryTeam: _primaryTeam,
      friendsTeam: _friendsTeam,
      coreTeam: _coreTeam,
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
      _TeamPage(
        data: data,
        t: _t,
        onCreateTeam: _createTeam,
      ),
      _AccountPage(
        data: data,
        t: _t,
        language: _language,
        soundOn: _soundOn,
        notificationsOn: _notificationsOn,
        onSetLanguage: _setLanguage,
        onSetSound: _setSound,
        onSetNotifications: _setNotifications,
        onOpenTerms: _openTermsDialog,
        onOpenPrivacy: _openPrivacyDialog,
        onOpenAntiCheat: _openAntiCheatDialog,
        onOpenCommercialLaw: _openCommercialLawDialog,
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
    final double userGoalProgress =
        (data.todaySummary.goalProgress).clamp(0.0, 1.0);

    final double globalParticipation =
        (data.global.activeUsers / 3000000).clamp(0.0, 1.0);

    final double worldEnergy =
        (data.global.totalStepsToday / 5000000000).clamp(0.0, 1.0);

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
          progress: userGoalProgress,
          globalEnergy: worldEnergy,
          participationDensity: globalParticipation,
          userEnergy: userGoalProgress,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: t('Today Steps', '今日の歩数'),
                value: _formatNumber(data.todaySummary.totalSteps),
                icon: Icons.directions_walk_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: t('Today CO₂ Reduction', '今日のCO₂削減量'),
                value: '${data.todaySummary.totalCo2KgSaved.toStringAsFixed(2)} kg',
                icon: Icons.eco_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: t('Goal Progress', '目標進捗'),
                value: '${(data.todaySummary.goalProgress * 100).round()}%',
                icon: Icons.track_changes_rounded,
                subtitle:
                    '${_formatNumber(data.todaySummary.totalSteps)} / ${_formatNumber(data.todaySummary.goalSteps)} ${t('steps', '歩')}',
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
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: t('Sync Status', '同期ステータス'),
                value: StepService.syncStatus,
                icon: Icons.sync_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: t('Data Source', 'データソース'),
                value: StepService.dataSource,
                icon: Icons.sensors_rounded,
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
        _SectionCard(
          title: t('Today', '今日'),
          child: Column(
            children: [
              _SignalRow(
                label: t('Steps', '歩数'),
                value: _formatNumber(data.todaySummary.totalSteps),
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: t('CO₂ Reduction', 'CO₂削減量'),
                value: '${data.todaySummary.totalCo2KgSaved.toStringAsFixed(2)} kg',
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: t('Prime Points', 'プライムポイント'),
                value: _formatNumber(data.todaySummary.totalPrimePoints),
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: t('Goal Progress', '目標進捗'),
                value: '${(data.todaySummary.goalProgress * 100).round()}%',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: t('This Week', '今週'),
          child: Column(
            children: [
              _SignalRow(
                label: t('Steps', '歩数'),
                value: _formatNumber(data.todaySummary.totalSteps * 7),
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: t('CO₂ Reduction', 'CO₂削減量'),
                value: '${(data.todaySummary.totalCo2KgSaved * 7).toStringAsFixed(2)} kg',
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: t('Prime Points', 'プライムポイント'),
                value: _formatNumber(data.todaySummary.totalPrimePoints * 7),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: t('This Month', '今月'),
          child: Column(
            children: [
              _SignalRow(
                label: t('Steps', '歩数'),
                value: _formatNumber(data.user.totalSteps),
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: t('CO₂ Reduction', 'CO₂削減量'),
                value: '${data.user.totalCo2KgSaved.toStringAsFixed(2)} kg',
              ),
              const SizedBox(height: 10),
              _SignalRow(
                label: t('Prime Points', 'プライムポイント'),
                value: _formatNumber(data.user.totalPrimePoints),
              ),
            ],
          ),
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
              const SizedBox(height: 10),
              _SignalRow(
                label: t('Data Source', 'データソース'),
                value: StepService.dataSource,
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
                value: '${(entry.value / 1000).toStringAsFixed(2)} kg',
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
    required this.onCreateTeam,
  });

  final _HomeDemoState data;
  final String Function(String en, String ja) t;
  final Future<void> Function(_TeamDraft draft) onCreateTeam;

  @override
  Widget build(BuildContext context) {
    final teams = [
      data.primaryTeam,
      if (data.primaryTeam.id != data.friendsTeam.id) data.friendsTeam,
      if (data.primaryTeam.id != data.coreTeam.id) data.coreTeam,
      if (data.primaryTeam.id != data.companyTeam.id) data.companyTeam,
      ...data.teamRank
          .where((entry) =>
              entry.relatedTeamId != null &&
              entry.relatedTeamId != data.primaryTeam.id &&
              entry.relatedTeamId != data.friendsTeam.id &&
              entry.relatedTeamId != data.coreTeam.id &&
              entry.relatedTeamId != data.companyTeam.id)
          .map(
            (entry) => TeamModel(
              id: entry.relatedTeamId!,
              name: entry.name,
              kind: TeamKind.team,
              ownerUserId: data.user.id,
              memberCount: 1,
              totalSteps: entry.value,
              totalCo2KgSaved:
                  ZeronImpactCalculator.calculateCo2KgSavedFromSteps(entry.value),
              totalPrimePoints: (entry.value ~/ 100),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              description: 'Saved local team',
              countryCode: data.user.countryCode,
              city: data.user.city,
            ),
          ),
    ];

    final uniqueTeams = <String, TeamModel>{};
    for (final team in teams) {
      uniqueTeams[team.id] = team;
    }

    final visibleTeams = uniqueTeams.values.toList();

    final totalMembers = visibleTeams.fold<int>(
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
                value: _formatNumber(visibleTeams.length),
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
          visibleTeams.length,
          (index) {
            final team = visibleTeams[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == visibleTeams.length - 1 ? 0 : 12),
              child: _TeamCard(
                team: team,
                isPrimary: team.id == data.primaryTeam.id,
                t: t,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _CreateTeamCard(
          t: t,
          onCreateTeam: onCreateTeam,
        ),
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
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    required this.onOpenAntiCheat,
    required this.onOpenCommercialLaw,
  });

  final _HomeDemoState data;
  final String Function(String en, String ja) t;
  final String language;
  final bool soundOn;
  final bool notificationsOn;
  final Future<void> Function(String value) onSetLanguage;
  final Future<void> Function(bool value) onSetSound;
  final Future<void> Function(bool value) onSetNotifications;
  final Future<void> Function() onOpenTerms;
  final Future<void> Function() onOpenPrivacy;
  final Future<void> Function() onOpenAntiCheat;
  final Future<void> Function() onOpenCommercialLaw;

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
              _SimpleArrowRow(
                label: t('Terms of Service', '利用規約'),
                onTap: onOpenTerms,
              ),
              const SizedBox(height: 14),
              _SimpleArrowRow(
                label: t('Privacy Policy', 'プライバシーポリシー'),
                onTap: onOpenPrivacy,
              ),
              const SizedBox(height: 14),
              _SimpleArrowRow(
                label: t('Anti-Cheat Policy', '不正防止ポリシー'),
                onTap: onOpenAntiCheat,
              ),
              const SizedBox(height: 14),
              _SimpleArrowRow(
                label: t('Commercial Law', '特定商取引法表記'),
                onTap: onOpenCommercialLaw,
              ),
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

class _GlobeHero extends StatefulWidget {
  const _GlobeHero({
    required this.title,
    required this.subtitle,
    required this.centerLabel,
    required this.centerSuffix,
    required this.bottomLabel,
    required this.progress,
    required this.globalEnergy,
    required this.participationDensity,
    required this.userEnergy,
  });

  final String title;
  final String subtitle;
  final String centerLabel;
  final String centerSuffix;
  final String bottomLabel;
  final double progress;
  final double globalEnergy;
  final double participationDensity;
  final double userEnergy;

  @override
  State<_GlobeHero> createState() => _GlobeHeroState();
}

class _GlobeHeroState extends State<_GlobeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _dragRotation = 0.0;
  double _dragTilt = -0.18;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 36),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xFFEAFBF2),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.60),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 1,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final double autoRotation = _controller.value * math.pi * 2;
                final double shimmer =
                    0.5 + (math.sin(_controller.value * math.pi * 2) * 0.5);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      _dragRotation += details.delta.dx * 0.008;
                      _dragTilt =
                          (_dragTilt - details.delta.dy * 0.0025).clamp(-0.45, 0.30);
                    });
                  },
                  child: CustomPaint(
                    painter: _EarthPainter(
                      progress: widget.progress,
                      rotation: autoRotation + _dragRotation,
                      tilt: _dragTilt,
                      globalEnergy: widget.globalEnergy,
                      participationDensity: widget.participationDensity,
                      userEnergy: widget.userEnergy,
                      shimmer: shimmer,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.centerLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.centerSuffix,
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
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.bottomLabel,
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

class _DualMetricGrid extends StatelessWidget {
  const _DualMetricGrid({
    required this.leftTitle,
    required this.leftValue,
    required this.leftIcon,
    required this.rightTitle,
    required this.rightValue,
    required this.rightIcon,
  });

  final String leftTitle;
  final String leftValue;
  final IconData leftIcon;
  final String rightTitle;
  final String rightValue;
  final IconData rightIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: leftTitle,
            value: leftValue,
            icon: leftIcon,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: rightTitle,
            value: rightValue,
            icon: rightIcon,
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
      case TeamKind.team:
        return t('Team', 'チーム');
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
    required this.onCreateTeam,
  });

  final String Function(String en, String ja) t;
  final Future<void> Function(_TeamDraft draft) onCreateTeam;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final draft = await showDialog<_TeamDraft>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _CreateTeamDialog(t: t),
        );

        if (draft == null) return;
        await onCreateTeam(draft);
      },
      child: Container(
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
                      'Build a new participation unit for friends, team or company.',
                      'フレンド、チーム、会社単位で新しい参加ユニットを作成します。',
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
    required this.onTap,
  });

  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
        ),
      ),
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
    required this.coreTeam,
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
  final TeamModel coreTeam;
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
    required this.rotation,
    required this.tilt,
    required this.globalEnergy,
    required this.participationDensity,
    required this.userEnergy,
    required this.shimmer,
  });

  final double progress;
  final double rotation;
  final double tilt;
  final double globalEnergy;
  final double participationDensity;
  final double userEnergy;
  final double shimmer;

  static const List<_EarthLightPoint> _cityLights = [
    _EarthLightPoint(lon: -74.0, lat: 40.7, strength: 1.00),
    _EarthLightPoint(lon: -118.2, lat: 34.0, strength: 0.90),
    _EarthLightPoint(lon: -87.6, lat: 41.8, strength: 0.72),
    _EarthLightPoint(lon: -95.3, lat: 29.7, strength: 0.64),
    _EarthLightPoint(lon: -46.6, lat: -23.5, strength: 0.90),
    _EarthLightPoint(lon: -58.4, lat: -34.6, strength: 0.62),
    _EarthLightPoint(lon: -0.1, lat: 51.5, strength: 0.90),
    _EarthLightPoint(lon: 2.35, lat: 48.85, strength: 0.82),
    _EarthLightPoint(lon: 13.4, lat: 52.5, strength: 0.70),
    _EarthLightPoint(lon: 37.6, lat: 55.7, strength: 0.74),
    _EarthLightPoint(lon: 139.7, lat: 35.6, strength: 1.00),
    _EarthLightPoint(lon: 135.5, lat: 34.7, strength: 0.68),
    _EarthLightPoint(lon: 126.9, lat: 37.5, strength: 0.78),
    _EarthLightPoint(lon: 121.4, lat: 31.2, strength: 0.92),
    _EarthLightPoint(lon: 116.4, lat: 39.9, strength: 0.80),
    _EarthLightPoint(lon: 114.1, lat: 22.3, strength: 0.82),
    _EarthLightPoint(lon: 103.8, lat: 1.35, strength: 0.72),
    _EarthLightPoint(lon: 77.2, lat: 28.6, strength: 0.82),
    _EarthLightPoint(lon: 72.8, lat: 19.0, strength: 0.72),
    _EarthLightPoint(lon: 55.2, lat: 25.2, strength: 0.60),
    _EarthLightPoint(lon: 31.2, lat: 30.0, strength: 0.56),
    _EarthLightPoint(lon: 28.0, lat: -26.2, strength: 0.58),
    _EarthLightPoint(lon: 151.2, lat: -33.8, strength: 0.74),
  ];

  static const List<_EarthLandEllipse> _landMasses = [
    _EarthLandEllipse(lon: -105, lat: 48, rx: 26, ry: 18, alpha: 0.90),
    _EarthLandEllipse(lon: -100, lat: 30, rx: 18, ry: 14, alpha: 0.88),
    _EarthLandEllipse(lon: -82, lat: 16, rx: 11, ry: 10, alpha: 0.72),
    _EarthLandEllipse(lon: -60, lat: -15, rx: 18, ry: 26, alpha: 0.88),
    _EarthLandEllipse(lon: -42, lat: 72, rx: 10, ry: 7, alpha: 0.56),
    _EarthLandEllipse(lon: 15, lat: 52, rx: 18, ry: 10, alpha: 0.82),
    _EarthLandEllipse(lon: 20, lat: 10, rx: 20, ry: 27, alpha: 0.88),
    _EarthLandEllipse(lon: 52, lat: 28, rx: 11, ry: 8, alpha: 0.72),
    _EarthLandEllipse(lon: 78, lat: 22, rx: 13, ry: 10, alpha: 0.82),
    _EarthLandEllipse(lon: 102, lat: 44, rx: 34, ry: 20, alpha: 0.92),
    _EarthLandEllipse(lon: 120, lat: 12, rx: 18, ry: 12, alpha: 0.74),
    _EarthLandEllipse(lon: 134, lat: -24, rx: 16, ry: 11, alpha: 0.82),
    _EarthLandEllipse(lon: 47, lat: -19, rx: 7, ry: 11, alpha: 0.60),
    _EarthLandEllipse(lon: 138, lat: 37, rx: 7, ry: 9, alpha: 0.68),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide * 0.355;
    final Rect wholeRect = Offset.zero & size;
    final Rect globeRect = Rect.fromCircle(center: center, radius: radius);

    final Paint bgGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF58E9D8).withOpacity(0.22 + (globalEnergy * 0.12)),
          const Color(0xFF16333C).withOpacity(0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.54, 1.0],
      ).createShader(wholeRect);

    canvas.drawRect(wholeRect, bgGlow);

    final Paint outerAura = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30)
      ..color = const Color(0xFF99FFE7)
          .withOpacity(0.12 + (participationDensity * 0.08));

    canvas.drawCircle(center, radius * 1.16, outerAura);

    final Paint atmosphere = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.045
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF94FFF1).withOpacity(0.00),
          const Color(0xFFB7FFF2).withOpacity(0.75),
          const Color(0xFF6EF0E0).withOpacity(0.28),
          const Color(0xFF94FFF1).withOpacity(0.00),
        ],
        stops: const [0.00, 0.16, 0.58, 1.00],
        transform: GradientRotation(rotation * 0.45),
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.08));

    final Paint ocean = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.24, -0.34),
        radius: 1.05,
        colors: [
          const Color(0xFF7EF7E7).withOpacity(0.82),
          const Color(0xFF0F5268).withOpacity(0.96),
          const Color(0xFF04141D),
        ],
        stops: const [0.0, 0.34, 1.0],
      ).createShader(globeRect);

    canvas.drawCircle(center, radius, ocean);

    canvas.save();
    canvas.clipPath(Path()..addOval(globeRect));

    final Paint deepShadow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.black.withOpacity(0.52),
          Colors.transparent,
          Colors.black.withOpacity(0.42),
        ],
        stops: const [0.0, 0.52, 1.0],
        transform: GradientRotation(rotation * 0.2),
      ).createShader(globeRect);

    canvas.drawRect(globeRect, deepShadow);

    final Paint rimLight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFC6FFF5).withOpacity(0.36 + (userEnergy * 0.10)),
          Colors.transparent,
          const Color(0xFF5FF0E0).withOpacity(0.10),
        ],
      ).createShader(globeRect);

    canvas.drawCircle(center, radius, rimLight);

    final Paint gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = Colors.white.withOpacity(0.06);

    for (int i = -2; i <= 2; i++) {
      final double lat = i * 22;
      _drawLatitude(canvas, center, radius, lat.toDouble(), tilt, gridPaint);
    }

    for (int i = 0; i < 8; i++) {
      final double lon = i * 45.0 + (rotation * 180 / math.pi);
      _drawLongitude(canvas, center, radius, lon, tilt, gridPaint);
    }

    for (final land in _landMasses) {
      _drawLand(canvas, center, radius, land);
    }

    _drawCityLights(canvas, center, radius);

    final Paint cloudPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withOpacity(0.07);

    for (int i = 0; i < 4; i++) {
      final double inset = radius * (0.08 + (i * 0.08));
      canvas.drawArc(
        Rect.fromLTWH(
          center.dx - radius + inset,
          center.dy - radius * 0.72 + (i * 8),
          (radius - inset) * 2,
          radius * 1.22 - (i * 12),
        ),
        -0.9,
        2.2,
        false,
        cloudPaint,
      );
    }

    final Paint vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.black.withOpacity(0.34),
        ],
        stops: const [0.0, 0.68, 1.0],
      ).createShader(globeRect);

    canvas.drawCircle(center, radius, vignette);

    canvas.restore();

    canvas.drawCircle(center, radius * 1.02, atmosphere);

    final Paint orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..color =
          const Color(0xFFB8FFE3).withOpacity(0.16 + (globalEnergy * 0.08));

    final Rect orbitA = Rect.fromCenter(
      center: center,
      width: radius * 2.72,
      height: radius * 1.20,
    );
    final Rect orbitB = Rect.fromCenter(
      center: center,
      width: radius * 2.38,
      height: radius * 2.38,
    );
    final Rect orbitC = Rect.fromCenter(
      center: center,
      width: radius * 2.44,
      height: radius * 1.62,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.24 + (rotation * 0.08));
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(orbitA, orbitPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.82 + (rotation * 0.05));
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(orbitC, orbitPaint);
    canvas.restore();

    final Paint orbitRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..color = Colors.white.withOpacity(0.10);

    canvas.drawOval(orbitB, orbitRing);

    final Paint progressArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.2
      ..shader = SweepGradient(
        colors: [
          const Color(0x00B8FFE3),
          const Color(0xFFCCFFF0).withOpacity(0.95),
          const Color(0xFF70F3E1).withOpacity(0.90),
          const Color(0x00B8FFE3),
        ],
        stops: const [0.00, 0.18, 0.54, 1.00],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(
        Rect.fromCircle(center: center, radius: radius + 22),
      );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 22),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      progressArc,
    );

    final Paint starPaint = Paint()
      ..color = Colors.white.withOpacity(0.62);

    final math.Random random = math.Random(71);
    for (int i = 0; i < 42; i++) {
      final double dx = random.nextDouble() * size.width;
      final double dy = random.nextDouble() * size.height;
      final Offset point = Offset(dx, dy);
      if ((point - center).distance > radius * 1.14) {
        canvas.drawCircle(point, 0.6 + random.nextDouble() * 1.5, starPaint);
      }
    }

    final Paint lensGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..color = const Color(0xFFBFFFF4)
          .withOpacity(0.04 + ((globalEnergy + shimmer) * 0.025));

    canvas.drawCircle(
      Offset(center.dx - radius * 0.28, center.dy - radius * 0.42),
      radius * 0.22,
      lensGlow,
    );
  }

  void _drawLand(
    Canvas canvas,
    Offset center,
    double radius,
    _EarthLandEllipse land,
  ) {
    final _SpherePoint projection = _project(
      lonDeg: land.lon,
      latDeg: land.lat,
      center: center,
      radius: radius,
    );

    if (!projection.visible) return;

    final double w = radius * (land.rx / 90) * projection.scale;
    final double h = radius * (land.ry / 90) * projection.scale * 1.12;

    final Rect rect = Rect.fromCenter(
      center: projection.offset,
      width: w * 2.0,
      height: h * 2.0,
    );

    final Paint landPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFC8FFE0).withOpacity(
            (0.20 + (participationDensity * 0.08)) * land.alpha * projection.alpha,
          ),
          const Color(0xFF9AEBC8).withOpacity(
            (0.10 + (globalEnergy * 0.08)) * land.alpha * projection.alpha,
          ),
          const Color(0xFF6CCCB2).withOpacity(
            0.05 * land.alpha * projection.alpha,
          ),
        ],
      ).createShader(rect);

    canvas.save();
    canvas.translate(projection.offset.dx, projection.offset.dy);
    canvas.rotate(-rotation * 0.06);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: w * 2.0,
        height: h * 2.0,
      ),
      landPaint,
    );
    canvas.restore();
  }

  void _drawCityLights(Canvas canvas, Offset center, double radius) {
    for (final city in _cityLights) {
      final _SpherePoint projection = _project(
        lonDeg: city.lon,
        latDeg: city.lat,
        center: center,
        radius: radius,
      );

      if (!projection.visible) continue;

      final double intensity = city.strength *
          (0.30 + (globalEnergy * 0.55) + (participationDensity * 0.22)) *
          projection.alpha;

      final double glowSize = radius * (0.010 + (city.strength * 0.010));

      final Paint glow = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = const Color(0xFFC7FFF1).withOpacity(intensity * 0.42);

      final Paint core = Paint()
        ..color = const Color(0xFFE7FFF8).withOpacity(intensity * 0.90);

      canvas.drawCircle(projection.offset, glowSize * 3.1, glow);
      canvas.drawCircle(projection.offset, glowSize, core);
    }
  }

  void _drawLatitude(
    Canvas canvas,
    Offset center,
    double radius,
    double latDeg,
    double tilt,
    Paint paint,
  ) {
    final double y = radius * math.sin(_degToRad(latDeg)) * math.cos(tilt);
    final double rx = radius * math.cos(_degToRad(latDeg));
    final double ry = rx * math.cos(tilt);

    final Rect rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - y * math.sin(tilt) * 0.18),
      width: rx * 2,
      height: ry * 2,
    );

    canvas.drawOval(rect, paint);
  }

  void _drawLongitude(
    Canvas canvas,
    Offset center,
    double radius,
    double lonDeg,
    double tilt,
    Paint paint,
  ) {
    final Path path = Path();
    bool started = false;

    for (double lat = -90; lat <= 90; lat += 2) {
      final _SpherePoint point = _project(
        lonDeg: lonDeg,
        latDeg: lat,
        center: center,
        radius: radius,
      );

      if (!point.visible) {
        started = false;
        continue;
      }

      if (!started) {
        path.moveTo(point.offset.dx, point.offset.dy);
        started = true;
      } else {
        path.lineTo(point.offset.dx, point.offset.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  _SpherePoint _project({
    required double lonDeg,
    required double latDeg,
    required Offset center,
    required double radius,
  }) {
    final double lon = _degToRad(lonDeg) + rotation;
    final double lat = _degToRad(latDeg);

    final double x = math.cos(lat) * math.sin(lon);
    final double y = math.sin(lat);
    final double z = math.cos(lat) * math.cos(lon);

    final double yTilt = (y * math.cos(tilt)) - (z * math.sin(tilt));
    final double zTilt = (y * math.sin(tilt)) + (z * math.cos(tilt));

    final bool visible = zTilt > -0.06;
    final double alpha = ((zTilt + 1) / 2).clamp(0.18, 1.0);
    final double scale = (0.84 + (zTilt * 0.18)).clamp(0.72, 1.0);

    return _SpherePoint(
      visible: visible,
      alpha: alpha,
      scale: scale,
      offset: Offset(
        center.dx + (x * radius),
        center.dy - (yTilt * radius),
      ),
    );
  }

  double _degToRad(double deg) {
    return deg * math.pi / 180.0;
  }

  @override
  bool shouldRepaint(covariant _EarthPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.tilt != tilt ||
        oldDelegate.globalEnergy != globalEnergy ||
        oldDelegate.participationDensity != participationDensity ||
        oldDelegate.userEnergy != userEnergy ||
        oldDelegate.shimmer != shimmer;
  }
}

class _SpherePoint {
  const _SpherePoint({
    required this.visible,
    required this.alpha,
    required this.scale,
    required this.offset,
  });

  final bool visible;
  final double alpha;
  final double scale;
  final Offset offset;
}

class _EarthLightPoint {
  const _EarthLightPoint({
    required this.lon,
    required this.lat,
    required this.strength,
  });

  final double lon;
  final double lat;
  final double strength;
}

class _EarthLandEllipse {
  const _EarthLandEllipse({
    required this.lon,
    required this.lat,
    required this.rx,
    required this.ry,
    required this.alpha,
  });

  final double lon;
  final double lat;
  final double rx;
  final double ry;
  final double alpha;
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

class _TeamDraft {
  const _TeamDraft({
    required this.name,
    required this.kind,
    required this.description,
    required this.makePrimary,
  });

  final String name;
  final TeamKind kind;
  final String description;
  final bool makePrimary;
}

class _CreateTeamDialog extends StatefulWidget {
  const _CreateTeamDialog({
    required this.t,
  });

  final String Function(String en, String ja) t;

  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TeamKind _kind = TeamKind.team;
  bool _makePrimary = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _create() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) return;

    Navigator.of(context).pop(
      _TeamDraft(
        name: name,
        kind: _kind,
        description: description.isEmpty
            ? widget.t(
                'Live local team running on this device.',
                'この端末上で稼働するローカルライブチームです。',
              )
            : description,
        makePrimary: _makePrimary,
      ),
    );
  }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.t('Create Team', 'チームを作成'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _FormField(
                controller: _nameController,
                label: widget.t('Team Name', 'チーム名'),
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _descriptionController,
                label: widget.t('Description', '説明'),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TeamKind>(
                    value: _kind,
                    dropdownColor: const Color(0xFF091015),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      DropdownMenuItem(
                        value: TeamKind.friends,
                        child: Text(widget.t('Friends', 'フレンズ')),
                      ),
                      DropdownMenuItem(
                        value: TeamKind.team,
                        child: Text(widget.t('Team', 'チーム')),
                      ),
                      DropdownMenuItem(
                        value: TeamKind.company,
                        child: Text(widget.t('Company', 'カンパニー')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _kind = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFFB8FFE3),
                title: Text(
                  widget.t('Set as Primary Team', 'メインチームに設定'),
                  style: const TextStyle(color: Colors.white),
                ),
                value: _makePrimary,
                onChanged: (value) {
                  setState(() {
                    _makePrimary = value;
                  });
                },
              ),
              const SizedBox(height: 10),
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
                  onPressed: _create,
                  child: Text(
                    widget.t('Create', '作成'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}