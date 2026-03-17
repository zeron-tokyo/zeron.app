import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zeron/app/zeron_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // グローバルエラーハンドリング
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };

  runZonedGuarded(
    () {
      runApp(const ZeronApp());
    },
    (error, stack) {},
  );
}