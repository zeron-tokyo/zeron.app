import 'package:flutter/material.dart';
import 'package:zeron/features/home/presentation/home_screen.dart';

class ZeronApp extends StatelessWidget {
  const ZeronApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const ZeronHomeScreen(),
    );
  }
}