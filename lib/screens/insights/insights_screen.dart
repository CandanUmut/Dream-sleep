import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../models/morning_reflection.dart';
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_chip.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final analyzableDreams = appState.analyzableDreams;
    final peopleCounts = appState.recurringPeopleCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final emotionCounts = appState.emotionFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final restfulness = appState.restfulnessSummary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final nightWake = appState.nightWakeSummary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final tagCounts = appState.tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final prefs = appState.preferences;

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
            title: const Text('Dream insights'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: DreamBackground(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
            child: analyzableDreams.isEmpty
                ? const Center(
                    child: EmptyState(
                      title: 'Allow insights to bloom',
                      subtitle: 'Mark a dream as “Okay to analyze” to unlock personalised reflections.',
                    ),
                  )
                : ListView(
                    children: [
                      FrostedCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'At a glance',
                              subtitle:
                                  'I’m watching over ${analyzableDreams.length} dreams. Here’s what they’re whispering.',
                              padding: const EdgeInsets.only(bottom: 12),
                            ),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                StatChip(
                                  label: 'lucid celebrations',
                                  value: '${appState.lucidDreamCount}',
                                  icon: Icons.auto_awesome,
                                ),
                                StatChip(
                                  label: 'nightmares soothed',
                                  value: '${appState.nightmareCount}',
                                  icon: Icons.nightlight_round,
                                ),
                                StatChip(
                                  label: 'positive feelings',
                                  value: '${(appState.positiveEmotionRatio * 100).round()}%',
                                  icon: Icons.favorite_outline,
                                ),
                                StatChip(
                                  label: 'dream tags tracked',
                                  value: '${tagCounts.length}',
                                  icon: Icons.bookmarks,
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
                            const SectionHeader(
                              title: 'Recurring companions',
                              subtitle: 'The people and presences who visit most often.',
                              padding: EdgeInsets.only(bottom: 16),
                            ),
                            if (peopleCounts.isEmpty)
                              const Text('No recurring people yet. Keep noticing who appears when you wake.')
                            else
                              Column(
                                children: [
                                  for (final entry in peopleCounts.take(5))
                                    _InsightTile(
                                      title: entry.key,
                                      value: '${entry.value} nights',
                                      progress: entry.value / peopleCounts.first.value,
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
                            const SectionHeader(
                              title: 'Emotion flow',
                              subtitle: 'Which feelings linger when you wake?',
                              padding: EdgeInsets.only(bottom: 16),
                            ),
                            if (emotionCounts.isEmpty)
                              const Text('Log feelings inside each dream to watch emotional trends unfold.')
                            else
                              Column(
                                children: [
                                  for (final entry in emotionCounts)
                                    _InsightTile(
                                      title: entry.key.label,
                                      value: '${entry.value} nights',
                                      progress: entry.value / emotionCounts.first.value,
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
                            const SectionHeader(
                              title: 'Nighttime rest',
                              subtitle: 'Morning reflections whisper about your body’s rest.',
                              padding: EdgeInsets.only(bottom: 16),
                            ),
                            if (restfulness.isEmpty)
                              const Text('Use the morning recall flow to log how rested you feel.'),
                            if (restfulness.isNotEmpty)
                              Column(
                                children: [
                                  for (final entry in restfulness)
                                    _InsightTile(
                                      title: _restfulnessLabel(entry.key),
                                      value: '${entry.value} mornings',
                                      progress: entry.value / restfulness.first.value,
                                    ),
                                ],
                              ),
                            if (nightWake.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text('Night wake-ups', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  for (final entry in nightWake)
                                    _InsightTile(
                                      title: _wakeLabel(entry.key),
                                      value: '${entry.value} nights',
                                      progress: entry.value / nightWake.first.value,
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (tagCounts.isNotEmpty)
                        FrostedCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(
                                title: 'Dream motifs',
                                subtitle: 'Tags that appear often in analyzable dreams.',
                                padding: EdgeInsets.only(bottom: 16),
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final entry in tagCounts.take(12))
                                    Chip(
                                      label: Text('${entry.key} · ${entry.value}'),
                                      backgroundColor: Colors.white.withOpacity(0.12),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      FrostedCard(
                        child: _LensTips(preferences: prefs),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  static String _restfulnessLabel(RestfulnessLevel level) {
    switch (level) {
      case RestfulnessLevel.rested:
        return 'Rested';
      case RestfulnessLevel.okay:
        return 'Okay';
      case RestfulnessLevel.drained:
        return 'Drained';
    }
  }

  static String _wakeLabel(NightWakeFrequency frequency) {
    switch (frequency) {
      case NightWakeFrequency.none:
        return 'Slept through';
      case NightWakeFrequency.once:
        return 'Woke once';
      case NightWakeFrequency.multiple:
        return 'Woke multiple times';
    }
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.title,
    required this.value,
    required this.progress,
  });

  final String title;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(value, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ],
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
      tips.add(_TipText(
        title: 'Psychology view',
        body:
            'Recurring stress dreams can be your mind gently processing unfinished worry. Try writing what still feels heavy before sleep and close with one self-kind sentence.',
      ));
    }
    if (preferences.lensPreference == ComfortLensPreference.islamic ||
        preferences.lensPreference == ComfortLensPreference.both) {
      tips.add(_TipText(
        title: 'Islamic view',
        body:
            'Nightmares are seen as whispers meant to upset you. They carry no authority. Say “A’udhu billahi min ash-shaytan ir-rajim,” turn to your right side, and trust that Allah keeps you safe.',
      ));
    }
    return Column(children: tips);
  }
}

class _TipText extends StatelessWidget {
  const _TipText({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    );
  }
}
