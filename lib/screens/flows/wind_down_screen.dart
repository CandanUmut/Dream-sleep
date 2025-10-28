import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sleep_routine.dart';
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';

class WindDownScreen extends StatelessWidget {
  const WindDownScreen({super.key});

  List<SleepRoutineStep> _buildSteps(UserPreferences preferences) {
    final steps = <SleepRoutineStep>[
      const SleepRoutineStep(
        title: 'Dim the lights',
        description: 'Soften screens and lamps to help melatonin flow.',
      ),
      const SleepRoutineStep(
        title: 'Release the day',
        description: 'Write one heavy thought, then close the notebook and exhale.',
      ),
      const SleepRoutineStep(
        title: 'Set intention',
        description: 'Quietly affirm: “Tonight I will remember my dreams.”',
      ),
    ];
    if (preferences.goals.contains(PrimaryGoal.spiritualComfort)) {
      steps.add(
        const SleepRoutineStep(
          title: 'Night prayers',
          description:
              'Recite Ayat al-Kursi, offer forgiveness, and rest on your right side knowing you are held by Allah’s mercy.',
        ),
      );
    }
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<AppState>().preferences;
    final steps = _buildSteps(preferences);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Night wind-down'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: steps.length + 1,
        itemBuilder: (context, index) {
          if (index == steps.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'If you wake feeling drained, be gentle with yourself. Rest comes first. Lucid dreams can wait for when your body feels nourished.',
              ),
            );
          }
          final step = steps[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(step.description),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
