import 'package:flutter/material.dart';
import 'package:zeron/features/home/presentation/home_screen.dart';

class ZeronApp extends StatelessWidget {
  const ZeronApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color baseBlack = Colors.black;
    const Color softWhite = Color(0xFFF5F5F5);

    final ThemeData theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: baseBlack,
      canvasColor: baseBlack,
      cardColor: baseBlack,
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
        surface: baseBlack,
        primary: softWhite,
        secondary: softWhite,
        onPrimary: baseBlack,
        onSecondary: baseBlack,
        onSurface: softWhite,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: softWhite,
        selectionColor: Color(0x33FFFFFF),
        selectionHandleColor: softWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: baseBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: softWhite,
        centerTitle: true,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
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
      darkTheme: theme,
      theme: theme,
      home: const ZeronHomeScreen(),
    );
  }
}