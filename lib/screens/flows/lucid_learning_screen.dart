import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_chip.dart';

class LucidLearningScreen extends StatefulWidget {
  static const routeName = '/lucid';

  const LucidLearningScreen({super.key});

  @override
  State<LucidLearningScreen> createState() => _LucidLearningScreenState();
}

class _LucidLearningScreenState extends State<LucidLearningScreen> {
  final Set<int> _expanded = {0};

  List<_LucidLesson> _lessonsFor(UserPreferences prefs) {
    final lessons = <_LucidLesson>[
      const _LucidLesson(
        title: 'Step 1 · Remember your dreams',
        body:
            'When you wake, stay still for 1–2 minutes and replay the dream. Write even a sentence. Each small note teaches your brain that dream memories matter.',
        practice: 'Morning journaling · Gentle recall',
      ),
      const _LucidLesson(
        title: 'Step 2 · Reality checks',
        body:
            'Pause during the day and do a quick test: count your fingers, reread a sentence, pinch your nose and try to breathe through it. Ask softly, “Am I dreaming?” Repetition plants the habit you’ll need inside the dream.',
        practice: 'Reality checks · Mindful pauses',
      ),
      const _LucidLesson(
        title: 'Step 3 · MILD intention',
        body:
            'If you wake in the night, recall the dream and whisper: “Next time I’m dreaming, I will remember I’m dreaming.” Visualise yourself back in that dream, noticing it’s a dream, then drift off with that intention.',
        practice: 'Night affirmations · Visualization',
      ),
      const _LucidLesson(
        title: 'Step 4 · Wake-Back-To-Bed',
        body:
            'After at least 5 hours of sleep, wake for 10 minutes, set your lucid intention, then return to bed. If you feel depleted the next day, pause this technique—your rest matters more than any lucid win.',
        practice: 'Gentle WBTB · Stretch and sip water',
      ),
      const _LucidLesson(
        title: 'Step 5 · In-dream stabilization',
        body:
            'When lucidity clicks, breathe slowly. Rub your dream-hands together, look around, touch the ground. Give yourself a gentle goal like “I will stay calm and observe for five breaths.”',
        practice: 'Grounding senses · Small goals',
      ),
    ];
    if (prefs.goals.contains(PrimaryGoal.spiritualComfort)) {
      lessons.add(
        const _LucidLesson(
          title: 'Spiritual reassurance',
          body:
              'If awareness arrives during a nightmare, call on Allah for protection and command the scene to stop. Nightmares hold no authority over you after waking.',
          practice: 'Dhikr · Protective supplications',
        ),
      );
    }
    return lessons;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppState>().preferences;
    final lessons = _lessonsFor(prefs);
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
            title: const Text('Gentle lucid path'),
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
                      const SectionHeader(
                        title: 'Your progress map',
                        subtitle: 'Move to the next level when the current one feels natural.',
                        padding: EdgeInsets.only(bottom: 16),
                      ),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          StatChip(
                            label: 'levels to explore',
                            value: '${lessons.length}',
                            icon: Icons.auto_stories,
                          ),
                          StatChip(
                            label: 'favourite focus',
                            value: prefs.goals.contains(PrimaryGoal.learnLucid)
                                ? 'Lucidity'
                                : 'Gentle recall',
                            icon: Icons.self_improvement,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile.adaptive(
                        value: prefs.realityCheckRemindersEnabled,
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: const Text('Reality check reminders'),
                        subtitle: const Text('Send 1–2 gentle prompts in the daytime. (Notifications stay on this device.)'),
                        onChanged: (value) => context.read<AppState>().updatePreferences(
                              prefs.copyWith(realityCheckRemindersEnabled: value),
                            ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                        child: Text('If reminders feel intrusive, switch them off anytime. Your rest comes first.'),
                      ),
                    ],
                  ),
                ),
                ExpansionPanelList(
                  elevation: 0,
                  expansionCallback: (index, isExpanded) {
                    setState(() {
                      if (isExpanded) {
                        _expanded.remove(index);
                      } else {
                        _expanded.add(index);
                      }
                    });
                  },
                  children: [
                    for (var i = 0; i < lessons.length; i++)
                      ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _expanded.contains(i),
                        headerBuilder: (context, _) => ListTile(
                          title: Text(lessons[i].title),
                          subtitle: Text(lessons[i].practice),
                        ),
                        body: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Text(lessons[i].body),
                        ),
                      ),
                  ],
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Daily anchor ideas',
                        subtitle: 'Pick one or two habits and keep them for a week.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          Chip(label: Text('Reality check reminder')),
                          Chip(label: Text('Evening gratitude')), 
                          Chip(label: Text('Visualise success')), 
                          Chip(label: Text('Stretch before bed')), 
                          Chip(label: Text('Morning breathing')), 
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LucidLesson {
  const _LucidLesson({required this.title, required this.body, required this.practice});

  final String title;
  final String body;
  final String practice;
}
