import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../flows/morning_recall_flow.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final prefs = appState.preferences;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: const Text('Morning “Did you dream?” prompt'),
            value: prefs.morningPromptEnabled,
            onChanged: (value) => appState.updatePreferences(
              prefs.copyWith(morningPromptEnabled: value),
            ),
          ),
          SwitchListTile(
            title: const Text('Night wind-down reminders'),
            value: prefs.nightWindDownEnabled,
            onChanged: (value) => appState.updatePreferences(
              prefs.copyWith(nightWindDownEnabled: value),
            ),
          ),
          ListTile(
            title: const Text('Comfort style'),
            subtitle: Text(prefs.lensPreference.name),
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (_) => _LensSheet(preferences: prefs),
            ),
          ),
          ListTile(
            title: const Text('Review privacy promise'),
            subtitle: const Text('Your dreams are yours. Always.'),
            onTap: () => showDialog(
              context: context,
              builder: (_) => const _PrivacyDialog(),
            ),
          ),
          ListTile(
            title: const Text('Reset all data'),
            subtitle: const Text('This clears dreams from the device (cannot be undone).'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reset all data?'),
                  content: const Text('This will delete every dream, reflection, and preference from this device.'),
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
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Quick morning check-in'),
            subtitle: const Text('Open the recall flow now.'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MorningRecallFlow()),
            ),
          ),
        ],
      ),
    );
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
