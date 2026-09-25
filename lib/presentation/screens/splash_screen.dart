import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Se muestra mientras se revisa si hay una sesión guardada.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_ipn.png', width: 120),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppTheme.guinda),
          ],
        ),
      ),
    );
  }
}
