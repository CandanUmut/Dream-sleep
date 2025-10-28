import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../providers/app_state.dart';
import '../../services/audio/audio_recorder_service.dart';

class MorningRecallFlow extends StatefulWidget {
  const MorningRecallFlow({super.key});

  @override
  State<MorningRecallFlow> createState() => _MorningRecallFlowState();
}

class _MorningRecallFlowState extends State<MorningRecallFlow> {
  int _step = 0;
  DreamEmotion? _selectedEmotion;
  final _noteController = TextEditingController();

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
    if (_selectedEmotion == null && _noteController.text.trim().isEmpty) {
      _logNoRecall();
      return;
    }
    final entry = DreamEntry(
      createdAt: DateTime.now(),
      emotions: _selectedEmotion != null ? [_selectedEmotion!] : [],
      fragments: [
        DreamFragmentField(label: 'Emotions', value: _selectedEmotion?.label ?? ''),
        DreamFragmentField(label: 'Notes', value: _noteController.text.trim()),
      ],
      onlyFeelingsLog: true,
    );
    await context.read<AppState>().upsertDream(entry);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morning recall'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning 🌙', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Do you remember a dream?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            if (_step == 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DreamEntryFlowShortcut()),
                    ),
                    child: const Text('Record dream'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => setState(() => _step = 1),
                    child: const Text('I only remember feelings'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _logNoRecall,
                    child: const Text('No recall today'),
                  ),
                ],
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: DreamEmotion.values
                          .map(
                            (emotion) => ChoiceChip(
                              label: Text(emotion.label),
                              selected: _selectedEmotion == emotion,
                              onSelected: (_) => setState(() => _selectedEmotion = emotion),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'One-line note',
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _saveFeelings,
                      child: const Text('Save feeling'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      backgroundColor: colorScheme.background,
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
