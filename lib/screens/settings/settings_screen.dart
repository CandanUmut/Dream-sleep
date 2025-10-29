import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
import '../flows/morning_recall_flow.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final prefs = appState.preferences;
    final goals = prefs.goals;
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
            title: const Text('Settings & privacy'),
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
                        title: 'Reminders',
                        subtitle: 'Choose how gently I nudge you.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      SwitchListTile.adaptive(
                        value: prefs.morningPromptEnabled,
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: const Text('Morning “Did you dream?” prompt'),
                        subtitle: const Text('Keeps the recall muscle awake even on quiet mornings.'),
                        onChanged: (value) => appState.updatePreferences(
                          prefs.copyWith(morningPromptEnabled: value),
                        ),
                      ),
                      SwitchListTile.adaptive(
                        value: prefs.nightWindDownEnabled,
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: const Text('Night wind-down reminders'),
                        subtitle: const Text('Prompts you to slow down, dim lights, and set intention.'),
                        onChanged: (value) => appState.updatePreferences(
                          prefs.copyWith(nightWindDownEnabled: value),
                        ),
                      ),
                      SwitchListTile.adaptive(
                        value: prefs.realityCheckRemindersEnabled,
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: const Text('Daytime reality check nudges'),
                        subtitle: const Text('Sends 1–2 gentle prompts while you’re awake. Turn off anytime.'),
                        onChanged: (value) => appState.updatePreferences(
                          prefs.copyWith(realityCheckRemindersEnabled: value),
                        ),
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Your focus',
                        subtitle: goals.isEmpty
                            ? 'Let me know what you need most so I can tailor tips.'
                            : 'Tap to adjust when your needs evolve.',
                        padding: const EdgeInsets.only(bottom: 12),
                        action: TextButton(
                          onPressed: () => _showGoalsSheet(context, prefs),
                          child: const Text('Edit'),
                        ),
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: goals.isEmpty
                            ? [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text('No goals selected yet'),
                                ),
                              ]
                            : goals
                                .map(
                                  (goal) => Chip(
                                    label: Text(_goalLabel(goal)),
                                    backgroundColor: Colors.white.withOpacity(0.14),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Comfort lens',
                        subtitle: 'Blend the type of reassurance that feels right tonight.',
                        padding: const EdgeInsets.only(bottom: 12),
                      ),
                      ListTile(
                        leading: const Icon(Icons.bubble_chart, color: Colors.white70),
                        title: const Text('Comfort style'),
                        subtitle: Text(_lensLabel(prefs.lensPreference)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => showModalBottomSheet(
                          context: context,
                          builder: (_) => _LensSheet(preferences: prefs),
                        ),
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Safety & care',
                        subtitle: 'Your dreams remain on this device unless you share them.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock, color: Colors.white70),
                        title: const Text('Review privacy promise'),
                        subtitle: const Text('Your dreams are yours. Always.'),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => const _PrivacyDialog(),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: Colors.white70),
                        title: const Text('Reset all data'),
                        subtitle: const Text('Clears dreams, feelings, and preferences from this device.'),
                        onTap: () => _confirmReset(context),
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Quick actions',
                        subtitle: 'Jump straight into a gentle practice.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      ListTile(
                        leading: const Icon(Icons.wb_twilight, color: Colors.white70),
                        title: const Text('Quick morning check-in'),
                        subtitle: const Text('Open the recall flow now.'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MorningRecallFlow()),
                        ),
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

  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'This will delete every dream, reflection, and preference from this device. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<AppState>().reset();
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }
  }

  void _showGoalsSheet(BuildContext context, UserPreferences preferences) {
    final appState = context.read<AppState>();
    final selected = preferences.goals.toSet();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What do you need most right now?', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: PrimaryGoal.values
                        .map(
                          (goal) => FilterChip(
                            label: Text(_goalLabel(goal)),
                            selected: selected.contains(goal),
                            onSelected: (_) {
                              setModalState(() {
                                if (selected.contains(goal)) {
                                  selected.remove(goal);
                                } else {
                                  selected.add(goal);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        appState.updatePreferences(preferences.copyWith(goals: selected));
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save focus'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _goalLabel(PrimaryGoal goal) {
    switch (goal) {
      case PrimaryGoal.improveRecall:
        return 'Remember dreams';
      case PrimaryGoal.sleepDeeper:
        return 'Sleep deeper';
      case PrimaryGoal.learnLucid:
        return 'Learn lucid dreaming';
      case PrimaryGoal.healNightmares:
        return 'Heal nightmares';
      case PrimaryGoal.spiritualComfort:
        return 'Spiritual comfort';
    }
  }

  String _lensLabel(ComfortLensPreference preference) {
    switch (preference) {
      case ComfortLensPreference.science:
        return 'Science / psychology guidance';
      case ComfortLensPreference.islamic:
        return 'Islamic spiritual comfort';
      case ComfortLensPreference.both:
        return 'Blend both views';
    }
  }
}

class _LensSheet extends StatelessWidget {
  const _LensSheet({required this.preferences});

  final UserPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Which comfort style feels best right now?', style: Theme.of(context).textTheme.titleMedium),
          RadioListTile(
            title: const Text('Science / psychology guidance'),
            value: ComfortLensPreference.science,
            groupValue: preferences.lensPreference,
            onChanged: (ComfortLensPreference? value) {
              if (value != null) {
                appState.updatePreferences(preferences.copyWith(lensPreference: value));
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile(
            title: const Text('Islamic spiritual comfort'),
            value: ComfortLensPreference.islamic,
            groupValue: preferences.lensPreference,
            onChanged: (ComfortLensPreference? value) {
              if (value != null) {
                appState.updatePreferences(preferences.copyWith(lensPreference: value));
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile(
            title: const Text('Both'),
            value: ComfortLensPreference.both,
            groupValue: preferences.lensPreference,
            onChanged: (ComfortLensPreference? value) {
              if (value != null) {
                appState.updatePreferences(preferences.copyWith(lensPreference: value));
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PrivacyDialog extends StatelessWidget {
  const _PrivacyDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Privacy promise'),
      content: const Text(
        'Your dreams are yours. We store them on this device. We never sell or share them. You choose what can be analyzed and what stays secret. You are safe here.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
