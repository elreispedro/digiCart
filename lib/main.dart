import 'package:digicart/src/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'src/models/media_collection.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MediaCollectionAdapter());
  Hive.registerAdapter(ColorAdapter());
  await Hive.openBox('mediaCollections');
  await Hive.openBox('settings');
  windowManager.waitUntilReadyToShow(windowOptionsApp, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setFullScreen(false);
    await windowManager.setTitleBarStyle(
      TitleBarStyle.normal,
      windowButtonVisibility: true,
    );
  });
  MediaKit.ensureInitialized();

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()),
  );
}
