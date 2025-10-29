import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_chip.dart';

class InsightsScreen extends StatelessWidget {
  static const routeName = '/insights';

  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final analyzableDreams = appState.analyzableDreams;

    final dreams = appState.dreams;
    final prefs = appState.preferences;

    final now = DateTime.now();
    final startOfWindow =
        DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final recentDreams = dreams
        .where((dream) =>
            dream.createdAt.isAfter(startOfWindow) ||
            dream.createdAt.isAtSameMomentAs(startOfWindow))
        .toList();
    final analyzableRecent = analyzableDreams
        .where((dream) =>
            dream.createdAt.isAfter(startOfWindow) ||
            dream.createdAt.isAtSameMomentAs(startOfWindow))
        .toList();

    final lucidsThisWeek =
        recentDreams.where((dream) => dream.lucid).length;
    final nightmaresThisWeek =
        recentDreams.where((dream) => dream.nightmare).length;

    final emotionCounts = <DreamEmotion, int>{};
    for (final dream in analyzableRecent) {
      for (final emotion in dream.emotions) {
        emotionCounts.update(emotion, (value) => value + 1,
            ifAbsent: () => 1);
      }
    }
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmotion =
        sortedEmotions.isNotEmpty ? sortedEmotions.first.key : null;

    String guidanceText() {
      final buffer = StringBuffer();
      if (topEmotion != null) {
        buffer.writeln(
            'This week your dreams most often felt ${topEmotion.label.toLowerCase()}.');
      }
      if (recentDreams.isEmpty) {
        buffer.write(
            'Log a few more dreams and I’ll spot deeper patterns for you.');
      } else {
        buffer.write(
            'Keep capturing even small fragments—the patterns grow clearer with every entry.');
      }
      return buffer.toString();
    }

    String comfortMessage() {
      switch (prefs.lensPreference) {
        case ComfortLensPreference.science:
          return
              'Psychology view: vivid or anxious dreams are your brain practising emotions safely in REM sleep. They are common and they pass. Ground yourself gently when you wake.';
        case ComfortLensPreference.islamic:
          return
              'Islamic view: nightmares are whispers without power. Say “A’udhu billahi min ash-shaytan ir-rajim,” turn to your right side, and know Allah protects you. You are not at fault for what you saw.';
        case ComfortLensPreference.both:
          return
              'Psychology view: stress dreams help your mind process the day. Islamic view: scary dreams are whispers meant only to upset you—they cannot harm you. You are wrapped in protection.';
      }
    }

    final body = analyzableDreams.isEmpty
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
                      title: 'This week',
                      subtitle: 'Gentle patterns from the past seven nights.',
                      padding: const EdgeInsets.only(bottom: 12),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        StatChip(
                          label: 'dreams logged',
                          value: '${recentDreams.length}',
                          icon: Icons.menu_book,
                        ),
                        StatChip(
                          label: 'lucid moments',
                          value: '$lucidsThisWeek',
                          icon: Icons.auto_awesome,
                        ),
                        StatChip(
                          label: 'nightmares noted',
                          value: '$nightmaresThisWeek',
                          icon: Icons.nightlight_round,
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
                    SectionHeader(
                      title: 'Emotional tone',
                      subtitle: topEmotion == null
                          ? 'Tag the feelings in each dream to help me track them.'
                          : 'Your dreams leaned toward ${topEmotion.label.toLowerCase()} this week.',
                      padding: const EdgeInsets.only(bottom: 12),
                    ),
                    Text(guidanceText()),
                  ],
                ),
              ),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Comfort guidance',
                      subtitle: 'Perspective chosen from your settings.',
                      padding: const EdgeInsets.only(bottom: 12),
                    ),
                    Text(comfortMessage()),
                  ],
                ),
              ),
            ],
          );

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
            child: body,
          ),
        ),
      ],
    );
  }
}
