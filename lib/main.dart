import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/dream_entry.dart';
import 'providers/app_state.dart';
import 'screens/flows/lucid_learning_screen.dart';
import 'screens/flows/nightmare_support_screen.dart';
import 'screens/flows/wind_down_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/insights/insights_screen.dart';
import 'screens/journal/dream_entry_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/settings/settings_screen.dart';
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
          if (!appState.isInitialized) {
            return MaterialApp(
              title: 'Dream Sleep',
              theme: DreamSleepTheme.dark,
              debugShowCheckedModeBanner: false,
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final initialRoute = appState.preferences.hasCompletedOnboarding
              ? HomeScreen.routeName
              : OnboardingFlow.routeName;

          return MaterialApp(
            title: 'Dream Sleep',
            theme: DreamSleepTheme.dark,
            debugShowCheckedModeBanner: false,
            initialRoute: initialRoute,
            routes: {
              HomeScreen.routeName: (_) => const HomeScreen(),
              OnboardingFlow.routeName: (_) => const OnboardingFlow(),
              InsightsScreen.routeName: (_) => const InsightsScreen(),
              LucidLearningScreen.routeName: (_) => const LucidLearningScreen(),
              NightmareSupportScreen.routeName: (_) => const NightmareSupportScreen(),
              WindDownScreen.routeName: (_) => const WindDownScreen(),
              SettingsScreen.routeName: (_) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case DreamEntryScreen.routeName:
                  final dream = settings.arguments as DreamEntry?;
                  return MaterialPageRoute(
                    builder: (_) => DreamEntryScreen(existingDream: dream),
                    settings: settings,
                  );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
