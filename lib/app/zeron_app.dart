import 'package:flutter/material.dart';
import 'package:zeron/features/home/presentation/home_screen.dart';

class ZeronApp extends StatelessWidget {
  const ZeronApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color baseBlack = Color(0xFF020406);
    const Color panel = Color(0xFF0A1115);
    const Color panelStrong = Color(0xFF0E181A);
    const Color softWhite = Color(0xFFF3FBF7);
    const Color mint = Color(0xFFB8FFE3);

    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: baseBlack,
      canvasColor: baseBlack,
      cardColor: panel,
      dividerColor: Colors.white10,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      shadowColor: Colors.transparent,
      fontFamilyFallback: const <String>[
        '.SF Pro Display',
        '.SF Pro Text',
        'Helvetica Neue',
        'Arial',
        'sans-serif',
      ],
      colorScheme: const ColorScheme.dark(
        surface: panel,
        primary: mint,
        secondary: softWhite,
        onPrimary: baseBlack,
        onSecondary: baseBlack,
        onSurface: softWhite,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: panelStrong,
        contentTextStyle: TextStyle(
          color: softWhite,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: softWhite,
        selectionColor: Color(0x33FFFFFF),
        selectionHandleColor: softWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: softWhite,
        centerTitle: true,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return mint;
          return Colors.white.withOpacity(0.90);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return mint.withOpacity(0.35);
          }
          return Colors.white.withOpacity(0.16);
        }),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 1,
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZERON',
      themeMode: ThemeMode.dark,
      theme: theme,
      darkTheme: theme,
      home: const ZeronHomeScreen(),
    );
  }
}