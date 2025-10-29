import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/night_note.dart';
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';

class NightmareSupportScreen extends StatefulWidget {
  static const routeName = '/soothe';

  const NightmareSupportScreen({super.key});

  @override
  State<NightmareSupportScreen> createState() => _NightmareSupportScreenState();
}

class _NightmareSupportScreenState extends State<NightmareSupportScreen> {
  final _rewriteController = TextEditingController();
  final _releaseController = TextEditingController();
  bool _showBreathGuide = false;

  @override
  void dispose() {
    _rewriteController.dispose();
    _releaseController.dispose();
    super.dispose();
  }

  Future<void> _saveNote({
    required String category,
    required TextEditingController controller,
    required String successMessage,
  }) async {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a few words first and I will hold them.')),
      );
      return;
    }
    final note = NightNote(
      createdAt: DateTime.now(),
      text: text,
      category: category,
    );
    await context.read<AppState>().addNightNote(note);
    if (!mounted) return;
    controller.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final prefs = appState.preferences;
    final lastRewrite = appState.latestNightNoteFor('nightmare_rewrite');
    final lastRelease = appState.latestNightNoteFor('nightmare_release');

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
            title: const Text('Nightmare soothe'),
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
                        'You’re awake. You’re safe.',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nightmares are your mind rehearsing safety. They can’t hurt you once your eyes are open. Feel the bed, the pillow, the air on your skin.',
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('60-second calm breath', style: Theme.of(context).textTheme.titleMedium),
                          TextButton(
                            onPressed: () => setState(() => _showBreathGuide = !_showBreathGuide),
                            child: Text(_showBreathGuide ? 'Hide guide' : 'Begin'),
                          ),
                        ],
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SizedBox(height: 12),
                            Text('Inhale 4 · Hold 2 · Exhale 6. Repeat four cycles and let the muscles around your eyes soften.'),
                            SizedBox(height: 16),
                            _BreathBar(),
                          ],
                        ),
                        crossFadeState: _showBreathGuide ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Grounding reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 12),
                      Text('• Sip water and feel the temperature.\n• Press your feet into the floor or mattress and notice their strength.\n• Name 5 things you can see, 4 you can feel, 3 you can hear.'),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rewrite the ending', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      const Text('Imagine the dream changing into something safe. Invite help, light, or protection.'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _rewriteController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Give the dream a kinder ending…',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _saveNote(
                          category: 'nightmare_rewrite',
                          controller: _rewriteController,
                          successMessage: 'I’ll remember that safer story with you.',
                        ),
                        icon: const Icon(Icons.bookmark_added_outlined),
                        label: const Text('Save this rewrite'),
                      ),
                      if (lastRewrite != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Last rewrite whispered:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(lastRewrite.text),
                      ],
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Set down the heavy thought', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      const Text('If something from the day is clinging to you, write it once and let me hold it.'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _releaseController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'What do you want to release?'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _saveNote(
                          category: 'nightmare_release',
                          controller: _releaseController,
                          successMessage: 'I’m holding that for you. Rest easy.',
                        ),
                        icon: const Icon(Icons.waving_hand_outlined),
                        label: const Text('Set it down'),
                      ),
                      if (lastRelease != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'You released earlier:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(lastRelease.text),
                      ],
                    ],
                  ),
                ),
                if (prefs.lensPreference == ComfortLensPreference.islamic ||
                    prefs.lensPreference == ComfortLensPreference.both)
                  FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Islamic comfort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        SizedBox(height: 12),
                        Text(
                          'Scary dreams are whispers with no power. Say “A’udhu billahi min ash-shaytan ir-rajim,” spit lightly to your left three times, and turn to your right side. Know that Allah protects you and you are not at fault.',
                        ),
                      ],
                    ),
                  )
                else
                  FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Psychology reminder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        SizedBox(height: 12),
                        Text(
                          'Nightmares are the brain’s way of processing strong feelings. They can feel intense, but they are practice, not prophecy. Safety returns when you open your eyes.',
                        ),
                      ],
                    ),
                  ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'If nightmares are frequent, violent, or make you dread sleep, please reach out to a licensed mental health professional or trusted spiritual advisor. You deserve support and restful nights.',
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

class _BreathBar extends StatefulWidget {
  const _BreathBar();

  @override
  State<_BreathBar> createState() => _BreathBarState();
}

class _BreathBarState extends State<_BreathBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value;
        double value;
        if (phase < 4 / 6) {
          value = phase / (4 / 6);
        } else if (phase < 5 / 6) {
          value = 1;
        } else {
          value = 1 - ((phase - 5 / 6) / (1 / 6));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 8),
            Text(
              value < 0.95
                  ? (value < 0.5 ? 'Inhale…' : 'Hold softly…')
                  : 'Exhale…',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
