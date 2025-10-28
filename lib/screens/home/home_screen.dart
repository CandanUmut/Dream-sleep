import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_chip.dart';
import '../flows/lucid_learning_screen.dart';
import '../flows/morning_recall_flow.dart';
import '../flows/wind_down_screen.dart';
import '../insights/insights_screen.dart';
import '../journal/dream_entry_screen.dart';
import '../journal/feelings_only_dialog.dart';
import '../journal/night_capture_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _DreamFilter { all, lucid, nightmares, feelings }

class _HomeScreenState extends State<HomeScreen> {
  _DreamFilter _filter = _DreamFilter.all;

  String _greeting() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Gentle morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Soft afternoon';
    } else {
      return 'Peaceful night';
    }
  }

  List<DreamEntry> _filteredDreams(AppState state) {
    final dreams = state.dreams;
    switch (_filter) {
      case _DreamFilter.all:
        return dreams;
      case _DreamFilter.lucid:
        return dreams.where((dream) => dream.lucid).toList();
      case _DreamFilter.nightmares:
        return dreams.where((dream) => dream.nightmare).toList();
      case _DreamFilter.feelings:
        return dreams.where((dream) => dream.onlyFeelingsLog).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dreams = _filteredDreams(appState);
    final filterLabels = {
      _DreamFilter.all: 'All',
      _DreamFilter.lucid: 'Lucid',
      _DreamFilter.nightmares: 'Nightmares',
      _DreamFilter.feelings: 'Feelings',
    };

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
            title: const Text('Dream-Sleep'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          body: DreamBackground(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 120),
            child: ListView(
              children: [
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting()}, dreamer',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appState.dreams.isEmpty
                            ? 'Begin your journey by recording your first dream. I will keep it safe.'
                            : 'Your dream world is growing. Keep capturing whispers right when you wake.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          StatChip(
                            label: 'night recall streak',
                            value: '${appState.recallStreak}',
                            icon: Icons.local_fire_department,
                          ),
                          StatChip(
                            label: 'dreams this week',
                            value: '${appState.dreamsLoggedThisWeek}',
                            icon: Icons.calendar_today,
                          ),
                          StatChip(
                            label: 'lucid moments',
                            value: '${appState.lucidDreamCount}',
                            icon: Icons.auto_awesome,
                          ),
                          StatChip(
                            label: 'feelings-only logs',
                            value: '${appState.feelingsOnlyCount}',
                            icon: Icons.favorite,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SectionHeader(
                  title: 'Capture tonight',
                  subtitle: 'Three quick ways to record what your heart experiences.',
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.mic_none),
                        label: const Text('Record a full dream'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DreamEntryScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.bubble_chart_outlined),
                        label: const Text('Log feelings only'),
                        onPressed: () async {
                          final feelings = await showDialog<DreamEntry>(
                            context: context,
                            builder: (_) => const FeelingsOnlyDialog(),
                          );
                          if (feelings != null && mounted) {
                            await context.read<AppState>().upsertDream(feelings);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Feelings saved with care.')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.nightlight_round),
                        label: const Text('Night capture mode'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NightCaptureScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Tonight’s gentle rituals',
                  subtitle: appState.preferences.nightWindDownEnabled
                      ? 'Wind-down reminders are on. You can switch them off any time.'
                      : 'Wind-down reminders are currently off—tap to revisit the flow.',
                ),
                FrostedCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.self_improvement, color: Colors.white70),
                        title: const Text('Begin wind-down'),
                        subtitle: const Text('Settle your body and heart in under two minutes.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WindDownScreen()),
                        ),
                      ),
                      const Divider(height: 24),
                      ListTile(
                        leading: const Icon(Icons.auto_awesome, color: Colors.white70),
                        title: const Text('Lucid learning path'),
                        subtitle: const Text('Grow awareness gently with levelled guidance.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LucidLearningScreen()),
                        ),
                      ),
                      const Divider(height: 24),
                      ListTile(
                        leading: const Icon(Icons.insights, color: Colors.white70),
                        title: const Text('Dream insights'),
                        subtitle: const Text('Find patterns and people that visit often.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const InsightsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Recent dreams',
                  subtitle: dreams.isEmpty
                      ? 'No entries for this filter yet. Capture tonight and the story appears here.'
                      : 'Tap a dream to revisit and edit the details.',
                  action: ToggleButtons(
                    onPressed: (index) {
                      setState(() => _filter = _DreamFilter.values[index]);
                    },
                    isSelected: _DreamFilter.values.map((f) => _filter == f).toList(),
                    borderRadius: BorderRadius.circular(18),
                    children: [
                      for (final filter in _DreamFilter.values)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(filterLabels[filter]!),
                        ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: dreams.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: EmptyState(
                            title: 'No dreams yet',
                            subtitle: 'Capture a dream or log a feeling to begin your archive.',
                          ),
                        )
                      : Column(
                          children: [
                            for (final dream in dreams.take(6))
                              FrostedCard(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: _DreamListTile(dream: dream),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MorningRecallFlow()),
            ),
            label: const Text('Morning recall'),
            icon: const Icon(Icons.bedtime),
          ),
        ),
      ],
    );
  }
}

class _DreamListTile extends StatelessWidget {
  const _DreamListTile({required this.dream});

  final DreamEntry dream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = dream.transcription.isNotEmpty
        ? dream.transcription
        : dream.fragments.map((fragment) => fragment.value).where((value) => value.isNotEmpty).join(' • ');
    final badges = <Widget>[];
    if (dream.lucid) {
      badges.add(_Badge(label: 'Lucid', icon: Icons.auto_awesome));
    }
    if (dream.nightmare) {
      badges.add(_Badge(label: 'Nightmare soothed', icon: Icons.shield_moon));
    }
    if (dream.onlyFeelingsLog) {
      badges.add(_Badge(label: 'Feelings only', icon: Icons.favorite));
    }

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DreamEntryScreen(existingDream: dream),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dream.title.isNotEmpty ? dream.title : 'Dream on ${dream.formattedDate}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: badges,
          ),
          const SizedBox(height: 8),
          Text(
            dream.formattedDate,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
