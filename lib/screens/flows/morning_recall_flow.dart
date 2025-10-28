import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../models/morning_reflection.dart';
import '../../providers/app_state.dart';
import '../../services/audio/audio_recorder_service.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';

class MorningRecallFlow extends StatefulWidget {
  const MorningRecallFlow({super.key});

  @override
  State<MorningRecallFlow> createState() => _MorningRecallFlowState();
}

class _MorningRecallFlowState extends State<MorningRecallFlow> {
  int _step = 0;
  final _noteController = TextEditingController();
  final _feelings = <DreamEmotion>{};
  RestfulnessLevel? _restfulness;
  NightWakeFrequency? _wakeFrequency;

  void _logNoRecall() {
    final entry = DreamEntry(
      createdAt: DateTime.now(),
      transcription: 'No recall today',
      fragments: const [
        DreamFragmentField(label: 'Notes', value: 'No recall today'),
      ],
    );
    context.read<AppState>().upsertDream(entry);
    Navigator.of(context).pop();
  }

  Future<void> _saveFeelings() async {
    if (_feelings.isEmpty && _noteController.text.trim().isEmpty) {
      _logNoRecall();
      return;
    }
    final entry = DreamEntry(
      createdAt: DateTime.now(),
      emotions: _feelings.toList(),
      fragments: [
        DreamFragmentField(
          label: 'Emotions',
          value: _feelings.map((emotion) => emotion.label).join(', '),
        ),
        DreamFragmentField(label: 'Notes', value: _noteController.text.trim()),
      ],
      onlyFeelingsLog: true,
    );
    await context.read<AppState>().upsertDream(entry);

    if (_restfulness != null || _wakeFrequency != null || _noteController.text.trim().isNotEmpty) {
      final reflection = MorningReflection(
        date: DateTime.now(),
        restfulness: _restfulness ?? RestfulnessLevel.okay,
        wakeFrequency: _wakeFrequency ?? NightWakeFrequency.none,
        notes: _noteController.text.trim(),
      );
      await context.read<AppState>().upsertReflection(reflection);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Text('Morning recall'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: DreamBackground(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressDots(currentStep: _step, totalSteps: 2),
                const SizedBox(height: 16),
                Text('Good morning 🌙', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  _step == 0
                      ? 'Do you remember a dream? Stay still for a moment and feel for the story.'
                      : 'Log the feeling, even if words are soft. This keeps the recall pathway alive.',
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _step == 0 ? _buildChoiceCard(context) : _buildFeelingCard(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceCard(BuildContext context) {
    return FrostedCard(
      key: const ValueKey('choice'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Choose what fits',
            subtitle: 'Each option takes less than a minute.',
            padding: EdgeInsets.only(bottom: 16),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DreamEntryFlowShortcut()),
            ),
            icon: const Icon(Icons.mic),
            label: const Text('Record dream now'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() => _step = 1),
            icon: const Icon(Icons.favorite_border),
            label: const Text('I remember a feeling'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _logNoRecall,
            child: const Text('No recall today'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingCard(BuildContext context) {
    return FrostedCard(
      key: const ValueKey('feelings'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Morning feeling log',
            subtitle: 'Pick every emotion that touched the dream.',
            padding: const EdgeInsets.only(bottom: 12),
            action: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _step = 0),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DreamEmotion.values
                .map(
                  (emotion) => FilterChip(
                    label: Text(emotion.label),
                    selected: _feelings.contains(emotion),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _feelings.add(emotion);
                        } else {
                          _feelings.remove(emotion);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'One-line note',
            ),
          ),
          const SizedBox(height: 24),
          Text('How rested do you feel?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: RestfulnessLevel.values
                .map(
                  (level) => ChoiceChip(
                    label: Text(_restfulnessLabel(level)),
                    selected: _restfulness == level,
                    onSelected: (selected) => setState(() => _restfulness = selected ? level : null),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Did you wake in the night?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: NightWakeFrequency.values
                .map(
                  (frequency) => ChoiceChip(
                    label: Text(_wakeLabel(frequency)),
                    selected: _wakeFrequency == frequency,
                    onSelected: (selected) => setState(() => _wakeFrequency = selected ? frequency : null),
                  ),
                )
                .toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveFeelings,
              child: const Text('Save this feeling'),
            ),
          ),
        ],
      ),
    );
  }

  String _restfulnessLabel(RestfulnessLevel level) {
    switch (level) {
      case RestfulnessLevel.rested:
        return 'Rested';
      case RestfulnessLevel.okay:
        return 'Okay';
      case RestfulnessLevel.drained:
        return 'Drained';
    }
  }

  String _wakeLabel(NightWakeFrequency frequency) {
    switch (frequency) {
      case NightWakeFrequency.none:
        return 'Slept through';
      case NightWakeFrequency.once:
        return 'Once';
      case NightWakeFrequency.multiple:
        return 'Multiple times';
    }
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < totalSteps; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: i == currentStep ? 32 : 12,
            decoration: BoxDecoration(
              color: i <= currentStep
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class DreamEntryFlowShortcut extends StatelessWidget {
  const DreamEntryFlowShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ready to record?',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DreamEntryShortcutRecorder()),
                );
              },
              child: const Text('Start voice note'),
            ),
          ],
        ),
      ),
    );
  }
}

class DreamEntryShortcutRecorder extends StatefulWidget {
  const DreamEntryShortcutRecorder({super.key});

  @override
  State<DreamEntryShortcutRecorder> createState() => _DreamEntryShortcutRecorderState();
}

class _DreamEntryShortcutRecorderState extends State<DreamEntryShortcutRecorder> {
  late AudioRecorderService _recorderService;
  bool _isRecording = false;
  String? _path;

  @override
  void initState() {
    super.initState();
    _recorderService = AudioRecorderService();
    _recorderService.init();
  }

  @override
  void dispose() {
    _recorderService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorderService.stopRecording();
      setState(() {
        _isRecording = false;
        _path = path;
      });
    } else {
      final path = await _recorderService.startRecording();
      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is needed.')),
        );
        return;
      }
      setState(() {
        _isRecording = true;
        _path = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleRecording,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 72,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording ? 'Tap to finish' : 'Tap to record',
                style: const TextStyle(color: Colors.white70),
              ),
              if (_path != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Saved locally. Add details when you are ready.',
                  style: const TextStyle(color: Colors.white54),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
