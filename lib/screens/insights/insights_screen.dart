import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final emotionFrequency = appState.emotionFrequency;
    final peopleCounts = appState.recurringPeopleCounts;
    final prefs = appState.preferences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream insights'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (appState.analyzableDreams.isEmpty)
            const Text('Mark dreams as “Okay to analyze” to see patterns.')
          else ...[
            _InsightCard(
              title: 'Recurring people',
              body: peopleCounts.isEmpty
                  ? 'No recurring people yet. Keep noticing who appears.'
                  : peopleCounts.entries
                      .map((entry) => '${entry.key}: ${entry.value} dreams')
                      .join('\n'),
            ),
            _InsightCard(
              title: 'Emotion flow',
              body: emotionFrequency.isEmpty
                  ? 'Log feelings to notice trends.'
                  : emotionFrequency.entries
                      .map((entry) => '${entry.key.label}: ${entry.value} nights')
                      .join('\n'),
            ),
            _InsightCard(
              title: 'Lucid celebrations',
              body: appState.lucidDreamCount > 0
                  ? 'You’ve had ${appState.lucidDreamCount} lucid dreams this week. Breathe, smile, and celebrate that awareness.'
                  : 'No lucid dreams yet. That’s okay—awareness grows slowly and kindly.',
            ),
          ],
          const SizedBox(height: 24),
          _LensTips(preferences: prefs),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(body),
          ],
        ),
      ),
    );
  }
}

class _LensTips extends StatelessWidget {
  const _LensTips({required this.preferences});

  final UserPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final tips = <Widget>[];
    if (preferences.lensPreference == ComfortLensPreference.science ||
        preferences.lensPreference == ComfortLensPreference.both) {
      tips.add(_InsightCard(
        title: 'Psychology view',
        body:
            'Recurring stress dreams can be your mind gently processing unfinished worry. Try writing what still feels heavy before sleep and close with one self-kind sentence.',
      ));
    }
    if (preferences.lensPreference == ComfortLensPreference.islamic ||
        preferences.lensPreference == ComfortLensPreference.both) {
      tips.add(_InsightCard(
        title: 'Islamic view',
        body:
            'Nightmares are seen as whispers meant to upset you. They carry no authority. Say “A’udhu billahi min ash-shaytan ir-rajim,” turn to your right side, and trust that Allah keeps you safe.',
      ));
    }
    return Column(children: tips);
  }
}
