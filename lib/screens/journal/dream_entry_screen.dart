import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../providers/app_state.dart';
import '../../services/audio/audio_recorder_service.dart';
import '../../services/transcription/local_transcription_service.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
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
  final _tagController = TextEditingController();
  late List<TextEditingController> _fragmentControllers;
  late List<DreamFragmentField> _fragments;
  late Set<DreamEmotion> _selectedEmotions;
  late List<String> _tags;
  bool _lucid = false;
  bool _nightmare = false;
  bool _private = true;
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
      DreamFragmentField(label: 'People / Characters'),
      DreamFragmentField(label: 'Places'),
      DreamFragmentField(label: 'Emotions'),
      DreamFragmentField(label: 'Symbols / Details'),
      DreamFragmentField(label: 'Notes'),
    ];
    _selectedEmotions = {};
    _tags = [];
    if (widget.existingDream != null) {
      final dream = widget.existingDream!;
      _titleController.text = dream.title;
      _transcriptionController.text = dream.transcription;
      _lucid = dream.lucid;
      _nightmare = dream.nightmare;
      _private = dream.privatePreference == DreamPrivacyPreference.private;
      _audioPath = dream.audioPath;
      if (dream.fragments.isNotEmpty) {
        _fragments = dream.fragments;
      }
      _selectedEmotions = dream.emotions.toSet();
      _tags = List<String>.from(dream.tags);
    }
    _fragmentControllers = _fragments.map((fragment) => TextEditingController(text: fragment.value)).toList();
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
    _tagController.dispose();
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

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      if (!_tags.contains(trimmed)) {
        _tags.add(trimmed);
      }
    });
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _addCustomFragment() {
    setState(() {
      final index = _fragments.length + 1;
      final newField = DreamFragmentField(label: 'Extra detail $index');
      _fragments = [..._fragments, newField];
      _fragmentControllers = [..._fragmentControllers, TextEditingController()];
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final fragments = <DreamFragmentField>[];
    for (var i = 0; i < _fragments.length; i++) {
      fragments.add(_fragments[i].copyWith(value: _fragmentControllers[i].text.trim()));
    }
    final entry = (widget.existingDream ?? DreamEntry(createdAt: DateTime.now())).copyWith(
      title: _titleController.text.trim(),
      transcription: _transcriptionController.text.trim(),
      fragments: fragments,
      emotions: _selectedEmotions.toList(),
      lucid: _lucid,
      nightmare: _nightmare,
      privatePreference: _private ? DreamPrivacyPreference.private : DreamPrivacyPreference.allowInsights,
      audioPath: _audioPath,
      tags: _tags,
    );
    await context.read<AppState>().upsertDream(entry);
    if (!mounted) return;
    setState(() => _isSaving = false);
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
            title: const Text('Dream entry'),
            backgroundColor: Colors.transparent,
            elevation: 0,
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
          body: DreamBackground(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 120),
            child: ListView(
              children: [
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Name and tag the dream',
                        subtitle: 'Optional, but helps insights recognise patterns.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      TextField(
                        controller: _titleController,
                        style: Theme.of(context).textTheme.titleLarge,
                        decoration: const InputDecoration(
                          labelText: 'Title (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Add a tag and press enter (e.g. ocean, childhood, flying)',
                        ),
                        onSubmitted: _addTag,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags
                            .map(
                              (tag) => InputChip(
                                label: Text(tag),
                                onDeleted: () => _removeTag(tag),
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
                      const SectionHeader(
                        title: 'Capture audio',
                        subtitle: 'Tap to record a whisper before it fades.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      _RecordingButton(
                        isRecording: _isRecording,
                        onTap: _toggleRecording,
                      ),
                      if (_audioPath != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Audio saved at $_audioPath',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _transcribe,
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Transcribe audio to text'),
                      ),
                    ],
                  ),
                ),
                FrostedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Dream story',
                        subtitle: 'Write every fragment you remember. Stay gentle and honest.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      TextField(
                        controller: _transcriptionController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Dream story or fragments',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('How did it feel?', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: DreamEmotion.values
                            .map(
                              (emotion) => FilterChip(
                                label: Text(emotion.label),
                                selected: _selectedEmotions.contains(emotion),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedEmotions.add(emotion);
                                    } else {
                                      _selectedEmotions.remove(emotion);
                                    }
                                  });
                                },
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
                      const SectionHeader(
                        title: 'Fragments & details',
                        subtitle: 'Jot little anchors so future-you can revisit clearly.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      for (var i = 0; i < _fragments.length; i++) ...[
                        TextField(
                          controller: _fragmentControllers[i],
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(labelText: _fragments[i].label),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _addCustomFragment,
                          icon: const Icon(Icons.add),
                          label: const Text('Add another detail prompt'),
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
                        title: 'How should I hold this dream?',
                        subtitle: 'These toggles shape insights and support I offer.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
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
                      if (_nightmare) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NightmareSupportScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.favorite),
                          label: const Text('Open soothing tools'),
                        ),
                      ],
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
}

class _RecordingButton extends StatelessWidget {
  const _RecordingButton({required this.isRecording, required this.onTap});

  final bool isRecording;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isRecording
                ? const [Color(0xFFED8070), Color(0xFFB53F4E)]
                : const [Color(0x337B5CD6), Color(0x2232479E)],
          ),
          borderRadius: BorderRadius.circular(45),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isRecording ? Icons.stop : Icons.mic, size: 36, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              isRecording ? 'Tap to finish recording' : 'Tap to record your voice',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
