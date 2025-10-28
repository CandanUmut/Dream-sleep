import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'theme.dart';

void main() {
  runApp(const DreamSleepApp());
}

class DreamSleepApp extends StatelessWidget {
  const DreamSleepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Dream Sleep',
            theme: DreamSleepTheme.dark,
            debugShowCheckedModeBanner: false,
            home: appState.preferences.hasCompletedOnboarding
                ? const HomeScreen()
                : const OnboardingFlow(),
          );
        },
      ),
    );
  }
}
