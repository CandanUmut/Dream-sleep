import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../providers/app_state.dart';
import '../../services/audio/audio_recorder_service.dart';
import '../../services/transcription/local_transcription_service.dart';
import '../flows/nightmare_support_screen.dart';

class DreamEntryScreen extends StatefulWidget {
  const DreamEntryScreen({super.key, this.existingDream});

  final DreamEntry? existingDream;

  @override
  State<DreamEntryScreen> createState() => _DreamEntryScreenState();
}

class _DreamEntryScreenState extends State<DreamEntryScreen> {
  final _titleController = TextEditingController();
  final _transcriptionController = TextEditingController();
  late List<TextEditingController> _fragmentControllers;
  late List<DreamFragmentField> _fragments;
  bool _lucid = false;
  bool _nightmare = false;
  bool _private = true;
  DreamEmotion? _selectedEmotion;
  bool _isRecording = false;
  String? _audioPath;
  late AudioRecorderService _recorderService;
  late LocalTranscriptionService _transcriptionService;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _recorderService = AudioRecorderService();
    _transcriptionService = LocalTranscriptionService();
    _fragments = [
      DreamFragmentField(label: 'People/Characters'),
      DreamFragmentField(label: 'Places'),
      DreamFragmentField(label: 'Emotions'),
      DreamFragmentField(label: 'Symbols/Details'),
      DreamFragmentField(label: 'Notes'),
    ];
    if (widget.existingDream != null) {
      final dream = widget.existingDream!;
      _titleController.text = dream.title;
      _transcriptionController.text = dream.transcription;
      _lucid = dream.lucid;
      _nightmare = dream.nightmare;
      _private = dream.privatePreference == DreamPrivacyPreference.private;
      _audioPath = dream.audioPath;
      _fragments = dream.fragments;
      _selectedEmotion = dream.emotions.isNotEmpty ? dream.emotions.first : null;
    }
    _fragmentControllers = _fragments.map((fragment) {
      final controller = TextEditingController(text: fragment.value);
      return controller;
    }).toList();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _recorderService.init();
    await _transcriptionService.init();
  }

  @override
  void dispose() {
    for (final controller in _fragmentControllers) {
      controller.dispose();
    }
    _titleController.dispose();
    _transcriptionController.dispose();
    _recorderService.dispose();
    _transcriptionService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorderService.stopRecording();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
    } else {
      final path = await _recorderService.startRecording();
      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is needed to record.')),
        );
        return;
      }
      setState(() {
        _isRecording = true;
        _audioPath = path;
      });
    }
  }

  Future<void> _transcribe() async {
    final text = await _transcriptionService.transcribeOnce();
    if (text.isEmpty) return;
    setState(() {
      _transcriptionController.text = text;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final fragments = <DreamFragmentField>[];
    for (var i = 0; i < _fragments.length; i++) {
      fragments.add(_fragments[i].copyWith(value: _fragmentControllers[i].text.trim()));
    }
    final emotions = <DreamEmotion>[];
    if (_selectedEmotion != null) {
      emotions.add(_selectedEmotion!);
    }
    final entry = (widget.existingDream ??
            DreamEntry(
              createdAt: DateTime.now(),
            ))
        .copyWith(
      title: _titleController.text.trim(),
      transcription: _transcriptionController.text.trim(),
      fragments: fragments,
      emotions: emotions,
      lucid: _lucid,
      nightmare: _nightmare,
      privatePreference:
          _private ? DreamPrivacyPreference.private : DreamPrivacyPreference.allowInsights,
      audioPath: _audioPath,
    );
    await context.read<AppState>().upsertDream(entry);
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream entry'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: const InputDecoration(
              labelText: 'Title (optional)',
            ),
          ),
          const SizedBox(height: 16),
          _RecordingButton(
            isRecording: _isRecording,
            onTap: _toggleRecording,
          ),
          if (_audioPath != null) ...[
            const SizedBox(height: 8),
            Text(
              'Audio saved locally at $_audioPath',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _transcribe,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Transcribe audio'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _transcriptionController,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Dream story or fragments',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
          const SizedBox(height: 24),
          for (var i = 0; i < _fragments.length; i++) ...[
            TextField(
              controller: _fragmentControllers[i],
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(labelText: _fragments[i].label),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            value: _lucid,
            title: const Text('Lucid moment'),
            subtitle: const Text('Celebrate awareness inside the dream.'),
            onChanged: (value) => setState(() => _lucid = value),
          ),
          SwitchListTile(
            value: _nightmare,
            title: const Text('Nightmare / distressing'),
            subtitle: const Text('We will offer gentle grounding if needed.'),
            onChanged: (value) => setState(() => _nightmare = value),
          ),
          SwitchListTile(
            value: _private,
            title: const Text('Keep this private'),
            subtitle: const Text('Private entries stay out of insights.'),
            onChanged: (value) => setState(() => _private = value),
          ),
          const SizedBox(height: 24),
          if (_nightmare)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NightmareSupportScreen(),
                ),
              ),
              icon: const Icon(Icons.favorite),
              label: const Text('I need soothing'),
            ),
        ],
      ),
    );
  }
}

class _RecordingButton extends StatelessWidget {
  const _RecordingButton({required this.isRecording, required this.onTap});

  final bool isRecording;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isRecording ? Colors.red.withOpacity(0.4) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isRecording ? Icons.stop : Icons.mic, size: 36, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                isRecording ? 'Tap to finish' : 'Tap to record dream',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
