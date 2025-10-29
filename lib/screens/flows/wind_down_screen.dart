import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/night_note.dart';
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';

class WindDownScreen extends StatefulWidget {
  static const routeName = '/winddown';

  const WindDownScreen({super.key});

  @override
  State<WindDownScreen> createState() => _WindDownScreenState();
}

class _WindDownScreenState extends State<WindDownScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveWindDownNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write one heavy thought first, then I’ll hold it.')),
      );
      return;
    }
    final note = NightNote(
      createdAt: DateTime.now(),
      text: text,
      category: 'winddown',
    );
    await context.read<AppState>().addNightNote(note);
    if (!mounted) return;
    _noteController.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('I’m keeping that safe for you. Sleep softly.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final preferences = appState.preferences;
    final lastNightNote = appState.latestNightNoteFor('winddown');
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
            title: const Text('Tonight’s wind-down'),
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
                    children: const [
                      Text(
                        'Your sleep cycles',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'You sleep in roughly 90-minute cycles. Early in the night your body repairs itself. Closer to morning, REM gets longer—that’s where vivid dreams bloom. Keeping a steady bedtime helps those cycles line up so recall becomes easier.',
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Dim the evening light',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Bright blue light tells your brain it’s daytime and delays melatonin. Give yourself 30–60 minutes of warm, low light before bed. Your mind will glide into sleep easier and protect the REM dreams you want to remember.',
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Set tonight’s intention', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 12),
                      Text(
                        'As you settle in, breathe gently and say, “Tonight I will remember my dreams.” This tiny ritual primes the memory circuits so morning recall feels natural. If you wake up in the night, whisper it again before drifting back.',
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Emotional unload',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      const Text('Write one heavy thought so your mind doesn’t have to shout it at you in a dream.'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'What are you setting down tonight?',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _saveWindDownNote,
                        icon: const Icon(Icons.nightlight_round),
                        label: const Text('Save this release'),
                      ),
                      if (lastNightNote != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Last night you let go of:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(lastNightNote.text),
                      ],
                    ],
                  ),
                ),
                if (preferences.lensPreference == ComfortLensPreference.islamic ||
                    preferences.lensPreference == ComfortLensPreference.both)
                  FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Spiritual night protection',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Recite Ayat al-Kursi or the last verses of Surah Al-Baqarah. Sleep on your right side and ask Allah to guard your dreams. Know that frightening images have no power over you—mercy surrounds your rest.',
                        ),
                      ],
                    ),
                  )
                else
                  FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Psychological comfort',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Lie on your side, breathe in for 4, hold 2, exhale 6. Tell yourself, “I did enough today. I can rest now.” Your nervous system listens when you speak kindly to it.',
                        ),
                      ],
                    ),
                  ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'If you wake tomorrow feeling depleted, be gentle. Deep rest is the priority. Lucid training and dream work can pause until your body feels nourished again.',
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
