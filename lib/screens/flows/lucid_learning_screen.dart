import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';

class LucidLearningScreen extends StatelessWidget {
  const LucidLearningScreen({super.key});

  List<_LucidLesson> _lessonsFor(UserPreferences prefs) {
    final lessons = <_LucidLesson>[
      const _LucidLesson(
        title: 'Level 1 · Foundations',
        body:
            'Keep journaling right when you wake. Whisper the intention “Tonight I will remember my dreams.” Stay still for a moment on waking and replay what you recall.',
      ),
      const _LucidLesson(
        title: 'Level 2 · Daytime awareness',
        body:
            'Pause gently during the day. Count your fingers. Read a sentence twice. Ask “Am I dreaming?” Each check plants seeds for awareness at night.',
      ),
      const _LucidLesson(
        title: 'Level 3 · MILD intention',
        body:
            'As you drift to sleep repeat softly: “Next time I’m dreaming, I will remember I’m dreaming.” Imagine staying calm when the dream becomes clear.',
      ),
      const _LucidLesson(
        title: 'Level 4 · Wake-Back-To-Bed',
        body:
            'Only after consistent sleep: rest ~5 hours, wake for 10 minutes to set intention, then return to bed. If you feel exhausted, stop immediately. Your health matters first.',
      ),
      const _LucidLesson(
        title: 'Level 5 · Stabilize gently',
        body:
            'Inside a lucid dream, rub your hands, look at the ground, spin slowly. Set a calm goal like “I will breathe and feel peace for five seconds.”',
      ),
    ];
    if (prefs.goals.contains(PrimaryGoal.spiritualComfort)) {
      lessons.add(
        const _LucidLesson(
          title: 'Spiritual reassurance',
          body:
              'If awareness arrives during a nightmare, call on Allah for protection and command the scene to stop. Nightmares hold no authority over you after waking.',
        ),
      );
    }
    return lessons;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppState>().preferences;
    final lessons = _lessonsFor(prefs);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gentle lucid path'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(lesson.body),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LucidLesson {
  const _LucidLesson({required this.title, required this.body});

  final String title;
  final String body;
}
