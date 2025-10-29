import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/night_note.dart';
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../services/storage/local_storage_service.dart';
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
  final Set<String> _completedActivities = <String>{};
  double _calmLevel = 3;
  String? _selectedIntention;
  final Set<int> _expandedTips = {0};

  static const _progressStorageKey = 'winddown_progress';

  @override
  void initState() {
    super.initState();
    _restoreProgress();
  }

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

  Future<void> _restoreProgress() async {
    final data = await LocalStorageService.instance.readSingleton(_progressStorageKey);
    if (!mounted || data == null) return;
    setState(() {
      final completed = (data['completedActivities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toSet();
      _completedActivities
        ..clear()
        ..addAll(completed);
      _calmLevel = (data['calmLevel'] as num?)?.toDouble() ?? 3;
      _selectedIntention = data['intention'] as String?;
      final expandedTips = (data['expandedTips'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toSet();
      if (expandedTips.isNotEmpty) {
        _expandedTips
          ..clear()
          ..addAll(expandedTips);
      }
    });
  }

  Future<void> _persistProgress() async {
    await LocalStorageService.instance.writeSingleton(_progressStorageKey, {
      'completedActivities': _completedActivities.toList(),
      'calmLevel': _calmLevel,
      'intention': _selectedIntention,
      'expandedTips': _expandedTips.toList(),
    });
  }

  void _updateCalmLevel(double value) {
    setState(() {
      _calmLevel = value;
    });
    _persistProgress();
  }

  void _toggleActivity(String id, bool value) {
    setState(() {
      if (value) {
        _completedActivities.add(id);
      } else {
        _completedActivities.remove(id);
      }
    });
    _persistProgress();
  }

  void _selectIntention(String intention) {
    setState(() {
      if (_selectedIntention == intention) {
        _selectedIntention = null;
      } else {
        _selectedIntention = intention;
      }
    });
    _persistProgress();
  }

  List<_WindDownTip> _tipsFor(UserPreferences preferences) {
    final tips = List<_WindDownTip>.of(_windDownTips);
    if (preferences.lensPreference == ComfortLensPreference.islamic ||
        preferences.lensPreference == ComfortLensPreference.both) {
      tips.add(const _WindDownTip(
        title: 'Spiritual night protection',
        body:
            'Recite Ayat al-Kursi or the last verses of Surah Al-Baqarah. Sleep on your right side and ask Allah to guard your dreams. Know that frightening images have no power over you—mercy surrounds your rest.',
      ));
    } else {
      tips.add(const _WindDownTip(
        title: 'Psychological comfort',
        body:
            'Lie on your side, breathe in for 4, hold 2, exhale 6. Tell yourself, “I did enough today. I can rest now.” Your nervous system listens when you speak kindly to it.',
      ));
    }
    tips.add(const _WindDownTip(
      title: 'In the morning',
      body:
          'If you wake tomorrow feeling depleted, be gentle. Deep rest is the priority. Lucid training and dream work can pause until your body feels nourished again.',
    ));
    return tips;
  }

  String _calmLabel(double value) {
    if (value <= 1.5) return 'Stirred up';
    if (value <= 2.5) return 'A little tense';
    if (value <= 3.5) return 'Settling';
    if (value <= 4.5) return 'Calm';
    return 'Deeply relaxed';
  }

  void _toggleTip(int index) {
    setState(() {
      if (_expandedTips.contains(index)) {
        _expandedTips.remove(index);
      } else {
        _expandedTips.add(index);
      }
    });
    _persistProgress();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final preferences = appState.preferences;
    final lastNightNote = appState.latestNightNoteFor('winddown');
    final tips = _tipsFor(preferences);
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
                    children: [
                      Text(
                        'How calm do you feel right now?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _calmLevel,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _calmLabel(_calmLevel),
                        onChanged: _updateCalmLevel,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _calmLabel(_calmLevel),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tonight’s actions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      for (final activity in _windDownActivities)
                        CheckboxListTile(
                          value: _completedActivities.contains(activity.id),
                          onChanged: (value) => _toggleActivity(activity.id, value ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(activity.title),
                          subtitle: Text(activity.description),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed ${_completedActivities.length} of ${_windDownActivities.length} steps',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set tonight’s intention',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final intention in _windDownIntentions)
                            ChoiceChip(
                              label: Text(intention),
                              selected: _selectedIntention == intention,
                              onSelected: (_) => _selectIntention(intention),
                            ),
                        ],
                      ),
                      if (_selectedIntention != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Hold this close as you drift: $_selectedIntention',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emotional unload',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                      const SizedBox(height: 8),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _noteController,
                        builder: (_, value, __) {
                          final length = value.text.trim().length;
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              length == 0 ? 'Nothing captured yet' : '$length characters captured',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                            ),
                          );
                        },
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
                for (var i = 0; i < tips.length; i++)
                  _WindDownTipCard(
                    tip: tips[i],
                    expanded: _expandedTips.contains(i),
                    onTap: () => _toggleTip(i),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

const List<_WindDownActivity> _windDownActivities = [
  _WindDownActivity(
    id: 'lights',
    title: 'Dim the evening light',
    description: 'Switch to warm, soft lighting for at least 30 minutes before sleep.',
  ),
  _WindDownActivity(
    id: 'devices',
    title: 'Put devices to rest',
    description: 'Silence notifications and place your phone away from the bed.',
  ),
  _WindDownActivity(
    id: 'body',
    title: 'Soften the body',
    description: 'Stretch or breathe slowly for two minutes to invite calm into your muscles.',
  ),
  _WindDownActivity(
    id: 'intention',
    title: 'Whisper your intention',
    description: 'Close your eyes and repeat your chosen phrase three gentle times.',
  ),
];

const List<String> _windDownIntentions = [
  'Tonight I welcome deep rest.',
  'Next time I dream, I will remember I am dreaming.',
  'I leave today behind with gratitude.',
  'My body is safe, my mind can soften.',
];

const List<_WindDownTip> _windDownTips = [
  _WindDownTip(
    title: 'How sleep cycles help you',
    body:
        'You sleep in roughly 90-minute cycles. Early cycles repair the body, later ones blossom into REM. A steady bedtime lets those vivid dreams surface more often.',
  ),
  _WindDownTip(
    title: 'Gentle light hygiene',
    body:
        'Bright blue light tells your brain it’s daytime. Swap to lamps or candles so melatonin can flow and your mind slips toward dreaming sooner.',
  ),
  _WindDownTip(
    title: 'Middle-of-the-night wake ups',
    body:
        'If you stir at 3am, stay soft. Breathe in for 4, hold for 2, exhale 6. Note a whisper of the dream, then say your intention again before returning to sleep.',
  ),
];

class _WindDownActivity {
  const _WindDownActivity({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

class _WindDownTip {
  const _WindDownTip({required this.title, required this.body});

  final String title;
  final String body;
}

class _WindDownTipCard extends StatelessWidget {
  const _WindDownTipCard({
    required this.tip,
    required this.expanded,
    required this.onTap,
  });

  final _WindDownTip tip;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FrostedCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tip.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState:
                      expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      tip.body,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
