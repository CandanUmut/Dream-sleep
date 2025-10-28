import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sleep_routine.dart';
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';

class WindDownScreen extends StatefulWidget {
  const WindDownScreen({super.key});

  @override
  State<WindDownScreen> createState() => _WindDownScreenState();
}

class _WindDownScreenState extends State<WindDownScreen> {
  final Set<int> _completedSteps = {};

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

  double _progress(int count) {
    if (count == 0) return 0;
    return _completedSteps.length / count;
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<AppState>().preferences;
    final steps = _buildSteps(preferences);
    final progress = _progress(steps.length);
    return Stack(
      children: [
        DreamBackground(
          useSafeArea: false,
          child: const SizedBox.expand(),
        ),
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Night wind-down'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: DreamBackground(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
            child: ListView(
              children: [
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress ${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Move slowly. Whisper your intention between steps. If a step doesn’t fit tonight, skip it kindly.',
                      ),
                    ],
                  ),
                ),
                for (var i = 0; i < steps.length; i++)
                  FrostedCard(
                    child: CheckboxListTile(
                      value: _completedSteps.contains(i),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _completedSteps.add(i);
                          } else {
                            _completedSteps.remove(i);
                          }
                        });
                      },
                      title: Text(steps[i].title),
                      subtitle: Text(steps[i].description),
                    ),
                  ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'If you wake feeling drained, be gentle with yourself. Rest comes first. Lucid dreams can wait for when your body feels nourished.',
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _completedSteps.clear()),
                  child: const Text('Reset tonight’s progress'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
