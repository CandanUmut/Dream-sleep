import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_chip.dart';

class LucidLearningScreen extends StatefulWidget {
  const LucidLearningScreen({super.key});

  @override
  State<LucidLearningScreen> createState() => _LucidLearningScreenState();
}

class _LucidLearningScreenState extends State<LucidLearningScreen> {
  final Set<int> _expanded = {0};

  List<_LucidLesson> _lessonsFor(UserPreferences prefs) {
    final lessons = <_LucidLesson>[
      const _LucidLesson(
        title: 'Level 1 · Foundations',
        body:
            'Keep journaling right when you wake. Whisper the intention “Tonight I will remember my dreams.” Stay still for a moment on waking and replay what you recall.',
        practice: 'Morning journaling · Evening intention',
      ),
      const _LucidLesson(
        title: 'Level 2 · Daytime awareness',
        body:
            'Pause gently during the day. Count your fingers. Read a sentence twice. Ask “Am I dreaming?” Each check plants seeds for awareness at night.',
        practice: 'Reality checks · Mindful pauses',
      ),
      const _LucidLesson(
        title: 'Level 3 · MILD intention',
        body:
            'As you drift to sleep repeat softly: “Next time I’m dreaming, I will remember I’m dreaming.” Imagine staying calm when the dream becomes clear.',
        practice: 'Night affirmations · Visualization',
      ),
      const _LucidLesson(
        title: 'Level 4 · Wake-Back-To-Bed',
        body:
            'Only after consistent sleep: rest ~5 hours, wake for 10 minutes to set intention, then return to bed. If you feel exhausted, stop immediately. Your health matters first.',
        practice: 'Gentle WBTB · Stretch and sip water',
      ),
      const _LucidLesson(
        title: 'Level 5 · Stabilize gently',
        body:
            'Inside a lucid dream, rub your hands, look at the ground, spin slowly. Set a calm goal like “I will breathe and feel peace for five seconds.”',
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
