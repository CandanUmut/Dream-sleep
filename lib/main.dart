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
import 'screens/journal/journal_overview_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/settings/settings_screen.dart';
import 'theme.dart';
import 'services/storage/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.warmUp();
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

          return MaterialApp(
            title: 'Dream Sleep',
            theme: DreamSleepTheme.dark,
            debugShowCheckedModeBanner: false,
            home: appState.preferences.hasCompletedOnboarding
                ? const HomeScreen()
                : const OnboardingFlow(),
            routes: {
              HomeScreen.routeName: (_) => const HomeScreen(),
              OnboardingFlow.routeName: (_) => const OnboardingFlow(),
              InsightsScreen.routeName: (_) => const InsightsScreen(),
              LucidLearningScreen.routeName: (_) => const LucidLearningScreen(),
              NightmareSupportScreen.routeName: (_) => const NightmareSupportScreen(),
              WindDownScreen.routeName: (_) => const WindDownScreen(),
              JournalOverviewScreen.routeName: (_) => const JournalOverviewScreen(),
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
