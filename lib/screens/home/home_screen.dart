import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../providers/app_state.dart';
import '../flows/lucid_learning_screen.dart';
import '../flows/morning_recall_flow.dart';
import '../flows/wind_down_screen.dart';
import '../insights/insights_screen.dart';
import '../journal/dream_entry_screen.dart';
import '../journal/feelings_only_dialog.dart';
import '../journal/night_capture_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream-Sleep'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HomeCard(
            title: 'Record dream',
            subtitle: 'Capture a dream in under 10 seconds.',
            actions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.mic_none),
                label: const Text('Record dream'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DreamEntryScreen()),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final feelings = await showDialog<DreamEntry>(
                    context: context,
                    builder: (_) => const FeelingsOnlyDialog(),
                  );
                  if (feelings != null) {
                    await context.read<AppState>().upsertDream(feelings);
                  }
                },
                child: const Text('Log feelings only'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NightCaptureScreen()),
                ),
                child: const Text('Night capture mode'),
              ),
            ],
            trailing: Text(
              appState.dreams.isEmpty
                  ? 'No dreams logged yet.'
                  : 'Last logged: ${appState.dreams.first.formattedDate}',
            ),
          ),
          _HomeCard(
            title: "Tonight's wind-down",
            subtitle: 'Settle your body and heart in under two minutes.',
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WindDownScreen()),
                ),
                child: const Text('Begin wind-down'),
              ),
            ],
            trailing: Text(
              appState.preferences.nightWindDownEnabled
                  ? 'Reminders on'
                  : 'Reminders off',
            ),
          ),
          _HomeCard(
            title: 'Learning & progress',
            subtitle: 'Grow your recall gently and celebrate each step.',
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LucidLearningScreen()),
                ),
                child: const Text('Lucid learning path'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InsightsScreen()),
                ),
                child: const Text('Dream insights'),
              ),
            ],
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This week: ${appState.dreams.length} dreams logged'),
                Text('${appState.nightmareCount} nightmares soothed'),
                Text('${appState.lucidDreamCount} lucid moments celebrated'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (appState.dreams.isNotEmpty)
            Text(
              'Recent dreams',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          const SizedBox(height: 12),
          for (final dream in appState.dreams.take(5))
            _DreamListTile(
              dream: dream,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MorningRecallFlow()),
        ),
        label: const Text('Morning recall'),
        icon: const Icon(Icons.bedtime),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.actions,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(subtitle),
                    ],
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodySmall!,
                      child: trailing!,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...actions,
          ],
        ),
      ),
    );
  }
}

class _DreamListTile extends StatelessWidget {
  const _DreamListTile({required this.dream});

  final DreamEntry dream;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Text(dream.title.isNotEmpty ? dream.title : 'Dream on ${dream.formattedDate}'),
      subtitle: Text(
        dream.transcription.isNotEmpty
            ? dream.transcription
            : dream.fragments.map((fragment) => fragment.value).join(' • '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (dream.lucid) const Text('Lucid ✨'),
          if (dream.nightmare) const Text('Nightmare 🤍'),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DreamEntryScreen(existingDream: dream),
        ),
      ),
    );
  }
}
