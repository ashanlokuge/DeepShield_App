import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/deepfake_detection_service.dart';
import 'theme/app_theme.dart';

/// Root widget: owns the single [DeepfakeDetectionService] instance
/// for the app's lifetime and wires up light/dark theming.
class DeepShieldApp extends StatefulWidget {
  const DeepShieldApp({super.key});

  @override
  State<DeepShieldApp> createState() => _DeepShieldAppState();
}

class _DeepShieldAppState extends State<DeepShieldApp> {
  final DeepfakeDetectionService _detectionService =
      DeepfakeDetectionService();

  @override
  void dispose() {
    _detectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepShield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: HomeScreen(detectionService: _detectionService),
    );
  }
}
