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
                document: _LocalizedDocument(
                  titleEn: 'Account Information',
                  titleJa: 'アカウント情報',
                  bodyEn: _buildAccountInfoText(),
                  bodyJa: _buildAccountInfoText(),
                ),
              ),
            );
          },
          onOpenCommercialLaw: () async {
            Navigator.of(context).pop();
            await showDialog<void>(
              context: this.context,
              builder: (_) => const _InfoDocumentDialog(
                document: _commercialLawDocument,
              ),
            );
          },
          onOpenTerms: () async {
            Navigator.of(context).pop();
            await showDialog<void>(
              context: this.context,
              builder: (_) => const _InfoDocumentDialog(
                document: _termsDocument,
              ),
            );
          },
          onOpenPrivacy: () async {
            Navigator.of(context).pop();
            await showDialog<void>(
              context: this.context,
              builder: (_) => const _InfoDocumentDialog(
                document: _privacyDocument,
              ),
            );
          },
        );
      },
    );
  }

  String _buildAccountInfoText() {
    return '''
Account Information

Username
${_username.isEmpty ? 'Not registered' : _username}

Email
${_email.isEmpty ? 'Not registered' : _email}

Country
${_country.isEmpty ? 'Not registered' : _country}

Region
${_region.isEmpty ? 'Not registered' : _region}

----

アカウント情報

ユーザー名
${_username.isEmpty ? '未登録' : _username}

メールアドレス
${_email.isEmpty ? '未登録' : _email}

国
${_country.isEmpty ? '未登録' : _country}

地域
${_region.isEmpty ? '未登録' : _region}
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

class _OpeningScene extends StatefulWidget {
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
  State<_OpeningScene> createState() => _OpeningSceneState();
}

class _OpeningSceneState extends State<_OpeningScene> {
  Offset _pointerPosition = const Offset(0, 0);
  bool _isPointerInside = false;

  void _setPointer(Offset value) {
    setState(() {
      _pointerPosition = value;
      _isPointerInside = true;
    });
  }

  void _clearPointer() {
    setState(() {
      _pointerPosition = const Offset(0, 0);
      _isPointerInside = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final double t = widget.controller.value;
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

        final double openingEnergy = (0.12 + (t * 0.18)).clamp(0.10, 0.42);

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerHover: (event) => _setPointer(event.localPosition),
          onPointerDown: (event) => _setPointer(event.localPosition),
          onPointerMove: (event) => _setPointer(event.localPosition),
          onPointerUp: (_) => _clearPointer(),
          onPointerCancel: (_) => _clearPointer(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await widget.onPrimaryTap();
            },
            onPanStart: (details) => _setPointer(details.localPosition),
            onPanUpdate: (details) => _setPointer(details.localPosition),
            onPanEnd: (_) => _clearPointer(),
            onPanCancel: _clearPointer,
            child: ColoredBox(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ZeronNoise(
                    presenceSeconds: presenceSeconds,
                    ambientStage: 2,
                    interactionEnergy: openingEnergy,
                    isPointerInside: _isPointerInside,
                  ),
                  Opacity(
                    opacity: backgroundOpacity,
                    child: ZeronBackground(
                      presenceSeconds: presenceSeconds,
                      ambientStage: 2,
                      interactionEnergy: openingEnergy,
                      pointerPosition: _pointerPosition,
                    ),
                  ),
                  Opacity(
                    opacity: glowOpacity,
                    child: ZeronDistortion(
                      presenceSeconds: presenceSeconds,
                      ambientStage: 2,
                      interactionEnergy: openingEnergy,
                      pointerPosition: _pointerPosition,
                    ),
                  ),
                  Opacity(
                    opacity: glowOpacity,
                    child: ZeronGlow(
                      presenceSeconds: presenceSeconds,
                      ambientStage: 2,
                      interactionEnergy: openingEnergy,
                      pointerPosition: _pointerPosition,
                      memoryPresence: 0.08,
                      memoryType: _isPointerInside ? 'active' : 'still',
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
                                    await widget.onOpenSettings();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Settings / 設定',
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
              'Settings / 設定',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            _SettingsRow(
              label: 'Account Information / アカウント情報',
              value: username.isEmpty ? 'Not registered / 未登録' : username,
              onTap: onOpenAccountInfo,
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              label: 'Specified Commercial Transactions Act / 特定商取引法表記',
              onTap: onOpenCommercialLaw,
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              label: 'Terms of Service / 利用規約',
              onTap: onOpenTerms,
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              label: 'Privacy Policy / プライバシーポリシー',
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

class _LocalizedDocument {
  const _LocalizedDocument({
    required this.titleEn,
    required this.titleJa,
    required this.bodyEn,
    required this.bodyJa,
  });

  final String titleEn;
  final String titleJa;
  final String bodyEn;
  final String bodyJa;
}

class _InfoDocumentDialog extends StatefulWidget {
  const _InfoDocumentDialog({
    required this.document,
    this.initialLanguage = 'en',
  });

  final _LocalizedDocument document;
  final String initialLanguage;

  @override
  State<_InfoDocumentDialog> createState() => _InfoDocumentDialogState();
}

class _InfoDocumentDialogState extends State<_InfoDocumentDialog> {
  late String _language;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final bool isJa = _language == 'ja';
    final String title =
        isJa ? widget.document.titleJa : widget.document.titleEn;
    final String content =
        isJa ? widget.document.bodyJa : widget.document.bodyEn;

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MiniLangButton(
                          label: 'EN',
                          selected: _language == 'en',
                          onTap: () {
                            setState(() {
                              _language = 'en';
                            });
                          },
                        ),
                        _MiniLangButton(
                          label: 'JP',
                          selected: _language == 'ja',
                          onTap: () {
                            setState(() {
                              _language = 'ja';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
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
                  child: Text(
                    isJa ? '閉じる' : 'Close',
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

class _MiniLangButton extends StatelessWidget {
  const _MiniLangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFB8FFE3).withOpacity(0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFFEFFFF8)
                : Colors.white.withOpacity(0.62),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

const _LocalizedDocument _commercialLawDocument = _LocalizedDocument(
  titleEn: 'Specified Commercial Transactions Act',
  titleJa: '特定商取引法表記',
  bodyEn: '''
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
''',
  bodyJa: '''
販売事業者
ZERON TOKYO

代表者
Hiroyuki Sugiura

連絡先メールアドレス
support@zeron.tokyo

販売価格
各購入ページまたはサブスクリプションページに表示します。

追加費用
インターネット接続料金、通信料金はユーザー負担です。

支払時期
購入またはサブスクリプション確定時に課金されます。

提供時期
特段の定めがない限り、決済確認後ただちに利用可能になります。

解約
継続課金の解約は、次回請求日前までにプラットフォーム設定から行えます。

返金
デジタルサービスの性質上、法令上必要な場合を除き、決済完了後の返金は原則行いません。

動作環境
対応するスマートフォン、OS、インターネット接続が必要です。
''',
);

const _LocalizedDocument _termsDocument = _LocalizedDocument(
  titleEn: 'Terms of Service',
  titleJa: '利用規約',
  bodyEn: '''
These Terms of Service govern access to ZERON and related participation features.

1. Users may create an account and participate in walking-based environmental initiatives.
2. Users must provide accurate registration information.
3. Fraudulent step activity, identity abuse, or system exploitation may result in suspension.
4. Future rewards, campaigns, and sponsor programs may have additional rules.
5. ZERON may update features, policies, and service details to improve platform operations.
6. Continued use of the service constitutes agreement to the latest terms.
''',
  bodyJa: '''
本利用規約は、ZERONおよび関連する参加機能へのアクセスと利用条件を定めるものです。

1. ユーザーはアカウントを作成し、歩行ベースの環境参加施策に参加できます。
2. ユーザーは正確な登録情報を提供しなければなりません。
3. 不正な歩数操作、なりすまし、システム悪用が確認された場合、利用停止となることがあります。
4. 将来の報酬、キャンペーン、スポンサー施策には追加ルールが適用される場合があります。
5. ZERONはサービス改善のため、機能・方針・提供内容を更新する場合があります。
6. 継続利用した場合、最新の利用規約に同意したものとみなします。
''',
);

const _LocalizedDocument _privacyDocument = _LocalizedDocument(
  titleEn: 'Privacy Policy',
  titleJa: 'プライバシーポリシー',
  bodyEn: '''
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
''',
  bodyJa: '''
ZERONは、ランキング、地域参加、将来の環境報酬機能を運営するために、必要最小限のアカウント情報および参加データを取得します。

取得する情報
- ユーザー名
- メールアドレス
- 国
- 地域
- 歩行参加データ
- サービス安定運用に必要な端末情報およびアプリ利用データ

利用目的
- アカウント作成および管理
- ランキング・地域参加機能の提供
- 不正防止
- サービス改善
- 将来のキャンペーンおよび報酬運営

第三者提供
ZERONは個人情報を販売しません。法令に基づく場合、または信頼できるインフラ提供パートナーを通じたサービス提供に必要な場合に限り共有されることがあります。

ユーザーの権利
ユーザーは、法令および運用上の要件に従い、保存された個人情報の訂正または削除を請求できます。
''',
);

const _LocalizedDocument _antiCheatDocument = _LocalizedDocument(
  titleEn: 'Anti-Cheat Policy',
  titleJa: '不正防止ポリシー',
  bodyEn: '''
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
''',
  bodyJa: '''
ZERONは、ランキング、スポンサー連動報酬、環境貢献の信頼性を守るため、不正防止ルールを適用します。

禁止行為
- spoofing、自動化、エミュレータ動作、非認可デバイスなどによる歩数の水増し
- 複数アカウントを用いたランキング操作
- アプリ挙動、API、ローカル保存、計測ロジックの改ざん
- ランキング、キャンペーン、報酬を歪める目的の不正参加全般

対応
ZERONは不審な挙動を調査し、スコア無効化、利用制限、停止、永久削除を含む措置を行う場合があります。

確認対象
公平性維持のため、参加記録、端末メタデータ、行動パターン、異常シグナルを確認する場合があります。

異議申立て
誤った対応だと考える場合、ユーザーはサポートへ審査を申請できます。
''',
);

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
      ? (persistedTotalSteps - liveTodaySteps).clamp(0, 1 << 30) +
          liveTodaySteps
      : persistedTotalSteps;

  final totalCo2 = persistedDate == todayKey
      ? (persistedTotalCo2 - liveSummary.totalCo2KgSaved)
              .clamp(0.0, double.infinity) +
          liveSummary.totalCo2KgSaved
      : persistedTotalCo2;

  final totalPoints = persistedDate == todayKey
      ? (persistedTotalPoints - liveSummary.totalPrimePoints)
              .clamp(0, 1 << 30) +
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
    _teams.addAll([
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
        description: 'Primary local contribution team.',
        countryCode: _user.countryCode,
        city: _user.city,
      ),
      TeamModel(
        id: 'company_${now.microsecondsSinceEpoch}',
        name: 'ZERON Company',
        kind: TeamKind.company,
        ownerUserId: _user.id,
        memberCount: 12,
        totalSteps: (_user.totalSteps * 8.2).round(),
        totalCo2KgSaved: _user.totalCo2KgSaved * 8.2,
        totalPrimePoints: (_user.totalPrimePoints * 8.2).round(),
        createdAt: now,
        updatedAt: now,
        description: 'Company participation and future carbon reporting layer.',
        countryCode: _user.countryCode,
        city: _user.city,
      ),
    ]);
  }

  final storedPrimaryId = prefs.getString(_persistPrimaryTeamIdKey);
  _primaryTeam = _teams.firstWhere(
    (team) => team.id == storedPrimaryId && team.kind == TeamKind.team,
    orElse: () => _teams.firstWhere(
      (team) => team.kind == TeamKind.team,
      orElse: () => _teams.first,
    ),
  );

  _coreTeam = _primaryTeam;
  _companyTeam = _firstTeamOfKind(TeamKind.company) ?? _primaryTeam;

  _monthlyEventTitle = 'Daily Earth Impact';
  _monthlyEventDescription =
      'Live walking data is transformed into visible CO₂ reduction and participation value.';
  _eventDaysLeft = 0;
  _sponsorReadyUsers = 1;

  await _saveTeams();
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
          'team' => TeamKind.team,
          'company' => TeamKind.company,
          _ => TeamKind.team,
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
          description: parts.length > 9 && parts[9].trim().isNotEmpty
              ? parts[9].trim()
              : null,
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
            TeamKind.team => 'team',
            TeamKind.company => 'company',
            TeamKind.friends => 'team',
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
          (_user.totalSteps - previousTodaySteps).clamp(0, 1 << 30) +
              summary.totalSteps;
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

  _coreTeam = _firstTeamOfKind(TeamKind.team) ?? _primaryTeam;
  _companyTeam = _firstTeamOfKind(TeamKind.company) ?? _primaryTeam;
}

void _rebuildComputedState() {
  final activeTeams = _teams.where((team) => team.kind == TeamKind.team).length;
  final activeCompanies =
      _teams.where((team) => team.kind == TeamKind.company).length;

  final totalTeamSteps = _teams.fold<int>(0, (sum, team) => sum + team.totalSteps);
  final totalTeamPoints =
      _teams.fold<int>(0, (sum, team) => sum + team.totalPrimePoints);
  final totalTeamCo2 =
      _teams.fold<double>(0.0, (sum, team) => sum + team.totalCo2KgSaved);
  final totalMembers = _teams.fold<int>(0, (sum, team) => sum + team.memberCount);

  final int todayCo2Grams = (_user.todayCo2KgSaved * 1000).round();

  _worldRank = <RankEntryModel>[
    RankEntryModel(
      id: 'world_you',
      scope: RankScope.world,
      rank: 1,
      name: _user.displayName ?? 'You',
      value: todayCo2Grams,
      label:
          '${_user.todayCo2KgSaved.toStringAsFixed(2)} kg CO₂ · ${_formatNumber(_user.todaySteps)} steps',
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
      label:
          '${_user.countryName} · ${_user.todayCo2KgSaved.toStringAsFixed(2)} kg CO₂ · ${_formatNumber(_user.todaySteps)} steps',
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
      label:
          '${_user.city} · ${_user.todayCo2KgSaved.toStringAsFixed(2)} kg CO₂ · ${_formatNumber(_user.todaySteps)} steps',
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

  _sponsorReadyUsers = totalMembers.clamp(1, 999999);
  _monthlyEventTitle =
      activeCompanies > 0 ? 'Company Carbon Participation' : 'Daily Earth Impact';
  _monthlyEventDescription =
      'Walking data is visualized as CO₂ reduction, team contribution, and future carbon-credit participation value.';
  _eventDaysLeft = 0;

  _global = GlobalImpactSnapshot(
    activeUsers: totalMembers.clamp(1, 999999),
    activeTeams: activeTeams.clamp(1, 999999),
    activeCountries: 1,
    activeCities: 1,
    totalStepsToday: _user.todaySteps,
    totalStepsThisMonth: totalTeamSteps == 0 ? _user.totalSteps : totalTeamSteps,
    totalCo2KgSaved: totalTeamCo2 == 0 ? _user.totalCo2KgSaved : totalTeamCo2,
    totalPrimePoints:
        totalTeamPoints == 0 ? _user.totalPrimePoints : totalTeamPoints,
    rewardPoolYen: (totalMembers * 100).clamp(100, 999999999),
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
    memberCount: draft.kind == TeamKind.company ? 12 : 1,
    totalSteps: draft.makePrimary
        ? _user.totalSteps
        : draft.kind == TeamKind.company
            ? (_user.totalSteps * 8.2).round()
            : 0,
    totalCo2KgSaved: draft.makePrimary
        ? _user.totalCo2KgSaved
        : draft.kind == TeamKind.company
            ? _user.totalCo2KgSaved * 8.2
            : 0,
    totalPrimePoints: draft.makePrimary
        ? _user.totalPrimePoints
        : draft.kind == TeamKind.company
            ? (_user.totalPrimePoints * 8.2).round()
            : 0,
    createdAt: now,
    updatedAt: now,
    description: draft.description,
    countryCode: _user.countryCode,
    city: _user.city,
  );

  _teams.add(newTeam);

  if (draft.kind == TeamKind.team && (draft.makePrimary || _teams.length == 1)) {
    _primaryTeam = newTeam;
    _syncTeamsWithUser();
  }

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
        document: _termsDocument,
      ),
    );
  }

  Future<void> _openPrivacyDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _InfoDocumentDialog(
        document: _privacyDocument,
      ),
    );
  }

  Future<void> _openCommercialLawDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _InfoDocumentDialog(
        document: _commercialLawDocument,
      ),
    );
  }

  Future<void> _openAntiCheatDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _InfoDocumentDialog(
        document: _antiCheatDocument,
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

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerHover: (event) {
        setState(() {
          _isPointerInside = true;
          _pointerPosition = event.localPosition;
          _interactionEnergy = (_interactionEnergy + 0.02).clamp(0.08, 0.60);
        });
      },
      onPointerDown: (event) {
        setState(() {
          _isPointerInside = true;
          _pointerPosition = event.localPosition;
          _interactionEnergy = (_interactionEnergy + 0.05).clamp(0.10, 0.68);
        });
      },
      onPointerMove: (event) {
        setState(() {
          _isPointerInside = true;
          _pointerPosition = event.localPosition;
          _interactionEnergy = (_interactionEnergy + 0.03).clamp(0.10, 0.68);
        });
      },
      onPointerUp: (_) {
        setState(() {
          _isPointerInside = false;
          _pointerPosition = const Offset(0, 0);
        });
      },
      onPointerCancel: (_) {
        setState(() {
          _isPointerInside = false;
          _pointerPosition = const Offset(0, 0);
        });
      },
      child: MouseRegion(
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
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            setState(() {
              _isPointerInside = true;
              _pointerPosition = details.localPosition;
              _interactionEnergy =
                  (_interactionEnergy + 0.04).clamp(0.10, 0.68);
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _isPointerInside = true;
              _pointerPosition = details.localPosition;
              _interactionEnergy =
                  (_interactionEnergy + 0.03).clamp(0.10, 0.68);
            });
          },
          onPanEnd: (_) {
            setState(() {
              _isPointerInside = false;
              _pointerPosition = const Offset(0, 0);
            });
          },
          onPanCancel: () {
            setState(() {
              _isPointerInside = false;
              _pointerPosition = const Offset(0, 0);
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

    final int teamTodaySteps = (data.user.todaySteps * 3.8).round();
    final double teamTodayCo2 = data.user.todayCo2KgSaved * 3.8;

    final int regionTodaySteps = (data.user.todaySteps * 14.2).round();
    final double regionTodayCo2 = data.user.todayCo2KgSaved * 14.2;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const SizedBox(height: 6),
        _PageHeader(
          title: t('Today', '今日'),
          subtitle: t(
            'Walking becomes visible value in your team, region, and the world.',
            '歩くことが、チーム・地域・世界で可視化される価値になります。',
          ),
        ),
        const SizedBox(height: 18),
        _GlobeHero(
          title: '${_formatNumber(data.global.totalStepsToday)} ${t('steps', '歩')}',
          subtitle: t('Global Participation Field', 'グローバル参加フィールド'),
          centerLabel: _formatNumber(data.user.todaySteps),
          centerSuffix: t('steps', '歩'),
          bottomLabel: t(
            'Tap and rotate to inspect contribution zones',
            '回転・タップで貢献エリアを確認',
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
                title: t('Today CO₂', '今日のCO₂削減量'),
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
                title: t('Data Source', 'データソース'),
                value: StepService.dataSource,
                icon: Icons.sensors_rounded,
                subtitle: StepService.syncStatus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: t('Team Contribution Today', '今日のチーム貢献'),
                value: '${teamTodayCo2.toStringAsFixed(2)} kg',
                icon: Icons.groups_rounded,
                subtitle:
                    '${_formatNumber(teamTodaySteps)} ${t('steps', '歩')}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: t('Region Contribution Today', '今日の地域貢献'),
                value: '${regionTodayCo2.toStringAsFixed(2)} kg',
                icon: Icons.public_rounded,
                subtitle:
                    '${_formatNumber(regionTodaySteps)} ${t('steps', '歩')}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title: t('Sync Status', '同期ステータス'),
          value: StepService.syncStatus,
          icon: Icons.sync_rounded,
          subtitle: t(
            'Live walking data is connected to today’s participation field.',
            'ライブ歩行データが今日の参加フィールドに接続されています。',
          ),
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
          title: t('Walk becomes value', '歩くことが価値になる'),
          body: t(
            'ZERON visualizes walking as CO₂ reduction, team contribution, regional participation, and future carbon-credit value.',
            'ZERONは歩行を、CO₂削減・チーム貢献・地域参加・将来のカーボンクレジット価値として可視化します。',
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
                value:
                    '${(data.todaySummary.totalCo2KgSaved * 7).toStringAsFixed(2)} kg',
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
      if (data.coreTeam.id != data.primaryTeam.id) data.coreTeam,
      if (data.companyTeam.id != data.primaryTeam.id &&
          data.companyTeam.id != data.coreTeam.id)
        data.companyTeam,
      ...data.teamRank
          .where((entry) =>
              entry.relatedTeamId != null &&
              entry.relatedTeamId != data.primaryTeam.id &&
              entry.relatedTeamId != data.coreTeam.id &&
              entry.relatedTeamId != data.companyTeam.id)
          .map(
            (entry) => TeamModel(
              id: entry.relatedTeamId!,
              name: entry.name,
              kind: TeamKind.team,
              ownerUserId: data.user.id,
              memberCount: 1,
              totalSteps: 0,
              totalCo2KgSaved: entry.value / 1000,
              totalPrimePoints: ((entry.value / 1000) * 100).round(),
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

    final visibleTeams = uniqueTeams.values.toList()
      ..sort((a, b) {
        if (a.kind == b.kind) {
          return b.totalCo2KgSaved.compareTo(a.totalCo2KgSaved);
        }
        if (a.kind == TeamKind.team) return -1;
        return 1;
      });

    final teamCount =
        visibleTeams.where((team) => team.kind == TeamKind.team).length;
    final companyCount =
        visibleTeams.where((team) => team.kind == TeamKind.company).length;
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
            'Build participation through Team and Company structures.',
            'Team と Company の構造で参加を可視化します。',
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: t('Teams', 'チーム数'),
                value: _formatNumber(teamCount),
                icon: Icons.groups_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: t('Companies', 'カンパニー数'),
                value: _formatNumber(companyCount),
                icon: Icons.apartment_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title: t('Members', 'メンバー数'),
          value: _formatNumber(totalMembers),
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        ...List.generate(
          visibleTeams.length,
          (index) {
            final team = visibleTeams[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == visibleTeams.length - 1 ? 0 : 12,
              ),
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

class _GlobeTag extends StatelessWidget {
  const _GlobeTag({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFB8FFE3).withOpacity(0.16)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? const Color(0xFFB8FFE3).withOpacity(0.28)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active
              ? const Color(0xFFEFFFF8)
              : Colors.white.withOpacity(0.72),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _GlobeMiniMetric extends StatelessWidget {
  const _GlobeMiniMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
              color: Colors.white.withOpacity(0.56),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobeHeroState extends State<_GlobeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _rotationX = 0.0;
  double _rotationY = -0.20;
  double _velocityX = 0.0;
  double _velocityY = 0.0;
  double _scale = 1.0;

  Timer? _inertiaTimer;
  int _selectedHotspot = 0;

  final List<({String en, String ja, IconData icon})> _hotspots = const [
    (
      en: 'Your activity area',
      ja: 'あなたの活動エリア',
      icon: Icons.person_pin_circle_rounded,
    ),
    (
      en: 'Team contribution zone',
      ja: 'チーム貢献エリア',
      icon: Icons.groups_rounded,
    ),
    (
      en: 'Company participation zone',
      ja: 'カンパニー参加エリア',
      icon: Icons.apartment_rounded,
    ),
    (
      en: 'World participation density',
      ja: '世界参加密度',
      icon: Icons.public_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _inertiaTimer?.cancel();
    super.dispose();
  }

  void _startInertia() {
    _inertiaTimer?.cancel();
    _inertiaTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        _rotationX += _velocityX;
        _rotationY += _velocityY;

        _velocityX *= 0.94;
        _velocityY *= 0.94;
        _rotationY = _rotationY.clamp(-1.15, 1.15);

        if (_velocityX.abs() < 0.0002 && _velocityY.abs() < 0.0002) {
          _inertiaTimer?.cancel();
        }
      });
    });
  }

  void _selectNextHotspot() {
    setState(() {
      _selectedHotspot = (_selectedHotspot + 1) % _hotspots.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotspot = _hotspots[_selectedHotspot];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.64),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xFFEAFBF2),
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _selectNextHotspot,
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_scale * details.scale).clamp(0.78, 1.85);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _velocityX = details.delta.dx * 0.0048;
                  _velocityY = details.delta.dy * 0.0042;
                  _rotationX += _velocityX;
                  _rotationY = (_rotationY + _velocityY).clamp(-1.15, 1.15);
                });
              },
              onPanEnd: (_) => _startInertia(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 286,
                          height: 286,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF6FFFE0).withOpacity(0.06),
                                const Color(0xFF4CB9FF).withOpacity(0.04),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..scale(_scale)
                          ..rotateX(_rotationY)
                          ..rotateY(_rotationX + _controller.value * math.pi * 2),
                        child: CustomPaint(
                          size: const Size(300, 300),
                          painter: _EarthPainter(
                            progress: widget.progress,
                            rotation: _rotationX + _controller.value * math.pi * 2,
                            tilt: _rotationY,
                            globalEnergy: widget.globalEnergy,
                            participationDensity: widget.participationDensity,
                            userEnergy: widget.userEnergy,
                            shimmer: _controller.value,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 18,
                    top: 20,
                    child: _GlobeTag(
                      label: 'YOU',
                      active: _selectedHotspot == 0,
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 46,
                    child: _GlobeTag(
                      label: 'TEAM',
                      active: _selectedHotspot == 1,
                    ),
                  ),
                  Positioned(
                    left: 30,
                    bottom: 48,
                    child: _GlobeTag(
                      label: 'COMPANY',
                      active: _selectedHotspot == 2,
                    ),
                  ),
                  Positioned(
                    right: 24,
                    bottom: 28,
                    child: _GlobeTag(
                      label: 'WORLD',
                      active: _selectedHotspot == 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Icon(
                  hotspot.icon,
                  color: const Color(0xFFB8FFE3),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hotspot.en,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${(widget.progress * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GlobeMiniMetric(
                  label: 'YOU',
                  value: '${widget.centerLabel} ${widget.centerSuffix}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlobeMiniMetric(
                  label: 'GOAL',
                  value: '${(widget.progress * 100).round()}%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlobeMiniMetric(
                  label: 'DENSITY',
                  value: '${(widget.participationDensity * 100).round()}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.bottomLabel,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12.5,
              height: 1.45,
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
                    : Colors.white.withOpacity(0.86),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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

  @override
  Widget build(BuildContext context) {
    final kindLabel = switch (team.kind) {
      TeamKind.team => t('Team', 'チーム'),
      TeamKind.company => t('Company', 'カンパニー'),
      TeamKind.friends => t('Team', 'チーム'),
    };

    return Container(
      decoration: _panelDecoration(highlighted: isPrimary),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPrimary
                      ? const Color(0xFFB8FFE3).withOpacity(0.16)
                      : Colors.white.withOpacity(0.06),
                ),
                child: Icon(
                  team.kind == TeamKind.company
                      ? Icons.apartment_rounded
                      : Icons.groups_rounded,
                  color: isPrimary
                      ? const Color(0xFFB8FFE3)
                      : Colors.white.withOpacity(0.78),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kindLabel,
                      style: TextStyle(
                        color: const Color(0xFFB8FFE3).withOpacity(0.92),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8FFE3).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFB8FFE3).withOpacity(0.20),
                    ),
                  ),
                  child: Text(
                    t('PRIMARY', 'メイン'),
                    style: const TextStyle(
                      color: Color(0xFFEFFFF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),
          if ((team.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              team.description!.trim(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniStatChip(
                label: t('Members', 'メンバー'),
                value: _formatNumber(team.memberCount),
              ),
              _MiniStatChip(
                label: t('Steps', '歩数'),
                value: _formatNumber(team.totalSteps),
              ),
              _MiniStatChip(
                label: t('CO₂', 'CO₂'),
                value: '${team.totalCo2KgSaved.toStringAsFixed(2)} kg',
              ),
              _MiniStatChip(
                label: t('Points', 'ポイント'),
                value: _formatNumber(team.totalPrimePoints),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
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

  Future<void> _showCreateDialog(BuildContext context) async {
    final result = await showDialog<_TeamDraft>(
      context: context,
      builder: (_) => _CreateTeamDialog(t: t),
    );

    if (result == null) return;
    await onCreateTeam(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('Create Team', 'チームを作成'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              'Build a Team or Company structure for participation, contribution tracking, and future carbon-credit expansion.',
              '参加、貢献可視化、将来のカーボンクレジット拡張に向けて Team または Company を作成します。',
            ),
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
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
              onPressed: () async => _showCreateDialog(context),
              child: Text(
                t('Create New Team', '新しいチームを作成'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  TeamKind _kind = TeamKind.team;
  bool _makePrimary = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.t(
            'Please enter a team name.',
            'チーム名を入力してください。',
          )),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _TeamDraft(
        name: name,
        description: description.isEmpty ? null : description,
        kind: _kind,
        makePrimary: _makePrimary,
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
              Text(
                widget.t('Create Team', 'チームを作成'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _FormField(
                controller: _nameController,
                label: widget.t('Team name', 'チーム名'),
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _descriptionController,
                label: widget.t('Description', '説明'),
              ),
              const SizedBox(height: 14),
              _KindSelector(
                selected: _kind,
                t: widget.t,
                onChanged: (value) {
                  setState(() {
                    _kind = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: CheckboxListTile(
                  value: _makePrimary,
                  activeColor: const Color(0xFFB8FFE3),
                  checkColor: Colors.black,
                  side: BorderSide(color: Colors.white.withOpacity(0.20)),
                  title: Text(
                    widget.t(
                      'Make this my primary team',
                      'このチームをメインチームにする',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    widget.t(
                      'Your live steps and CO₂ totals will attach to this team.',
                      'ライブ歩数とCO₂累計をこのチームに紐付けます。',
                    ),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.64),
                      fontSize: 12,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _makePrimary = value ?? false;
                    });
                  },
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
                  onPressed: _submit,
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

class _KindSelector extends StatelessWidget {
  const _KindSelector({
    required this.selected,
    required this.t,
    required this.onChanged,
  });

  final TeamKind selected;
  final String Function(String en, String ja) t;
  final ValueChanged<TeamKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <({TeamKind kind, String label})>[
      (kind: TeamKind.team, label: t('Team', 'チーム')),
      (kind: TeamKind.company, label: t('Company', 'カンパニー')),
    ];

    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: items.map((item) {
          final isSelected = selected == item.kind;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.kind),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFB8FFE3).withOpacity(0.13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFB8FFE3).withOpacity(0.24)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFFEFFFF8)
                        : Colors.white.withOpacity(0.60),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
          value.isEmpty ? '-' : value,
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
      onTap: () async => onTap(),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.62),
          ),
        ],
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
          child: _LangPill(
            label: 'English',
            selected: selected == 'en',
            onTap: () async => onChanged('en'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LangPill(
            label: '日本語',
            selected: selected == 'ja',
            onTap: () async => onChanged('ja'),
          ),
        ),
      ],
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill({
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
      onTap: () async => onTap(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFB8FFE3).withOpacity(0.13)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFFB8FFE3).withOpacity(0.24)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected
                ? const Color(0xFFEFFFF8)
                : Colors.white.withOpacity(0.66),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: const Color(0xFFB8FFE3),
          onChanged: (next) async => onChanged(next),
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

  IconData _iconFor(int i) {
    switch (i) {
      case 0:
        return Icons.today_outlined;
      case 1:
        return Icons.dashboard_outlined;
      case 2:
        return Icons.emoji_events_outlined;
      case 3:
        return Icons.groups_outlined;
      case 4:
        return Icons.person_outline_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF071015).withOpacity(0.90),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.32),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: List.generate(5, (i) {
            final selected = i == index;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFB8FFE3).withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconFor(i),
                        size: 20,
                        color: selected
                            ? const Color(0xFFB8FFE3)
                            : Colors.white.withOpacity(0.58),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        labelBuilder(i),
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFFEFFFF8)
                              : Colors.white.withOpacity(0.56),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _HomeDemoState {
  const _HomeDemoState({
    required this.user,
    required this.todaySummary,
    required this.global,
    required this.primaryTeam,
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

class _TeamDraft {
  const _TeamDraft({
    required this.name,
    required this.kind,
    required this.makePrimary,
    this.description,
  });

  final String name;
  final String? description;
  final TeamKind kind;
  final bool makePrimary;
}

class _EarthPainter extends CustomPainter {
  _EarthPainter({
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

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.34;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final outerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7BFFD2).withOpacity(0.18 + userEnergy * 0.10),
          const Color(0xFF44C7FF).withOpacity(0.06 + globalEnergy * 0.08),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 1.9),
      );

    canvas.drawCircle(center, radius * 1.82, outerGlow);

    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          -0.28 + math.cos(rotation) * 0.08,
          -0.24 + math.sin(rotation * 0.8) * 0.06,
        ),
        radius: 1.08,
        colors: [
          const Color(0xFF17343B),
          const Color(0xFF0C171D),
          const Color(0xFF05090C),
        ],
        stops: const [0.0, 0.58, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, spherePaint);

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.06 + participationDensity * 0.04)
      ..strokeWidth = 1.0;

    for (int i = -3; i <= 3; i++) {
      final y =
          center.dy + i * radius * 0.24 + math.sin(tilt) * i * radius * 0.05;
      final ry = radius * (0.22 + (1 - (i.abs() / 4)) * 0.08);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, y),
          width: radius * 1.90,
          height: ry * 2,
        ),
        gridPaint,
      );
    }

    for (int i = -4; i <= 4; i++) {
      final xShift =
          math.sin(rotation + i * 0.55) * radius * 0.26 * math.cos(tilt);
      final path = Path();
      for (double y = -radius; y <= radius; y += 4) {
        final normalized = y / radius;
        final curve = math.sin(normalized * math.pi * 0.92) * radius * 0.18;
        final x = center.dx +
            (i * radius * 0.18) +
            xShift +
            curve * math.sin(rotation + i * 0.35);
        final py = center.dy + y;
        if (y == -radius) {
          path.moveTo(x, py);
        } else {
          path.lineTo(x, py);
        }
      }
      canvas.drawPath(path, gridPaint);
    }

    final continentsPaint = Paint()
      ..color = const Color(0xFF91FFD8).withOpacity(0.16 + shimmer * 0.06)
      ..style = PaintingStyle.fill;

    final continentStroke = Paint()
      ..color = const Color(0xFFC6FFEE).withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final continents = _projectedContinents(center, radius);
    for (final path in continents) {
      canvas.drawPath(path, continentsPaint);
      canvas.drawPath(path, continentStroke);
    }

    final activityPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final dots = _activityDots(center, radius);
    for (final dot in dots) {
      final alpha = dot.$3;
      activityPaint.color = dot.$4.withOpacity(alpha);
      canvas.drawCircle(dot.$1, dot.$2, activityPaint);
    }

    final atmosphere = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          const Color(0xFF6FFFE0).withOpacity(0.10),
          const Color(0xFF4CB9FF).withOpacity(0.28 + globalEnergy * 0.16),
          const Color(0xFFB8FFE3).withOpacity(0.14 + progress * 0.10),
          const Color(0xFF6FFFE0).withOpacity(0.10),
        ],
      ).createShader(rect);

    canvas.restore();

    canvas.drawCircle(center, radius + 1.4, atmosphere);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.08);

    canvas.drawCircle(center, radius * 1.18, ringPaint);

    final progressPaintBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.08);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          const Color(0xFF6FFFE0),
          const Color(0xFF4CB9FF),
          const Color(0xFFB8FFE3),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 1.35),
      );

    final progressRect =
        Rect.fromCircle(center: center, radius: radius * 1.35);

    canvas.drawArc(
      progressRect,
      -math.pi / 2,
      math.pi * 2,
      false,
      progressPaintBg,
    );
    canvas.drawArc(
      progressRect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  List<Path> _projectedContinents(Offset center, double radius) {
    final List<List<Offset>> continentShapes = [
      [
        const Offset(-0.48, -0.10),
        const Offset(-0.62, -0.18),
        const Offset(-0.68, -0.06),
        const Offset(-0.58, 0.08),
        const Offset(-0.50, 0.20),
        const Offset(-0.42, 0.14),
        const Offset(-0.44, -0.02),
      ],
      [
        const Offset(-0.10, -0.24),
        const Offset(0.10, -0.30),
        const Offset(0.28, -0.18),
        const Offset(0.24, 0.00),
        const Offset(0.12, 0.08),
        const Offset(-0.04, 0.02),
        const Offset(-0.16, -0.12),
      ],
      [
        const Offset(0.26, 0.10),
        const Offset(0.40, 0.06),
        const Offset(0.52, 0.16),
        const Offset(0.48, 0.30),
        const Offset(0.34, 0.34),
        const Offset(0.24, 0.22),
      ],
      [
        const Offset(0.56, -0.28),
        const Offset(0.68, -0.22),
        const Offset(0.72, -0.10),
        const Offset(0.60, -0.06),
        const Offset(0.50, -0.16),
      ],
    ];

    return continentShapes.map((points) {
      final path = Path();
      for (int i = 0; i < points.length; i++) {
        final projected = _projectPoint(points[i], center, radius);
        if (i == 0) {
          path.moveTo(projected.dx, projected.dy);
        } else {
          path.lineTo(projected.dx, projected.dy);
        }
      }
      path.close();
      return path;
    }).toList();
  }

  Offset _projectPoint(Offset point, Offset center, double radius) {
    final double x = point.dx;
    final double y = point.dy + tilt * 0.35;

    final double rotatedX = x * math.cos(rotation) - y * math.sin(rotation) * 0.12;
    final double depth = 1 - (rotatedX.abs() * 0.22);
    final double px = center.dx + rotatedX * radius * 1.05;
    final double py = center.dy + y * radius * (0.94 + depth * 0.10);

    return Offset(px, py);
  }

  List<(Offset, double, double, Color)> _activityDots(
    Offset center,
    double radius,
  ) {
    final dots = <(Offset, double, double, Color)>[];
    final seeds = <Offset>[
      const Offset(-0.44, -0.04),
      const Offset(-0.54, 0.14),
      const Offset(0.02, -0.18),
      const Offset(0.18, -0.02),
      const Offset(0.34, 0.20),
      const Offset(0.58, -0.16),
    ];

    for (int i = 0; i < seeds.length; i++) {
      final p = _projectPoint(seeds[i], center, radius);
      final wave = (math.sin(rotation * 1.7 + i * 0.8) * 0.5 + 0.5);
      final alpha = 0.12 + wave * (0.20 + participationDensity * 0.24);
      final dotRadius = radius * (0.02 + wave * 0.016);
      final color = i.isEven
          ? const Color(0xFF6FFFE0)
          : const Color(0xFF4CB9FF);
      dots.add((p, dotRadius, alpha, color));
    }

    return dots;
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

BoxDecoration _panelDecoration({bool highlighted = false}) {
  return BoxDecoration(
    color: const Color(0xFF071015).withOpacity(highlighted ? 0.82 : 0.72),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? const Color(0xFFB8FFE3).withOpacity(0.20)
          : Colors.white.withOpacity(0.08),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.24),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    final reverseIndex = text.length - i;
    buffer.write(text[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

String _formatNumberDouble(double value) {
  final fixed = value.toStringAsFixed(value >= 100 ? 0 : 2);
  final parts = fixed.split('.');
  final whole = int.tryParse(parts.first) ?? 0;
  final wholeFormatted = _formatNumber(whole);
  if (parts.length == 1) return wholeFormatted;
  if (int.tryParse(parts[1]) == 0) return wholeFormatted;
  return '$wholeFormatted.${parts[1]}';
}

String _planLabel(ZeronPlan plan) {
  switch (plan) {
    case ZeronPlan.free:
      return 'Free';
    case ZeronPlan.plus:
      return 'Plus';
    case ZeronPlan.pro:
      return 'Pro';
    case ZeronPlan.enterprise:
      return 'Enterprise';
  }
}