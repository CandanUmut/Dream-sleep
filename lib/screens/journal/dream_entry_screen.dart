import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dream_entry.dart';
import '../../providers/app_state.dart';
import '../../services/recording/recording_service.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
import '../flows/nightmare_support_screen.dart';

class DreamEntryScreen extends StatefulWidget {
  static const routeName = '/journal/new';

  const DreamEntryScreen({super.key, this.existingDream});

  final DreamEntry? existingDream;

  @override
  State<DreamEntryScreen> createState() => _DreamEntryScreenState();
}

enum _CaptureMode { voice, text }

class _DreamEntryScreenState extends State<DreamEntryScreen> {
  late final RecordingService _recordingService;
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
  bool _voiceSupported = false;
  _CaptureMode _mode = _CaptureMode.text;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _recordingService = createRecordingService();
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
    _initializeRecording();
  }

  Future<void> _initializeRecording() async {
    await _recordingService.initialize();
    if (!mounted) return;
    final supported = _recordingService.isSupported;
    setState(() {
      _voiceSupported = supported;
      _mode = supported ? _CaptureMode.voice : _CaptureMode.text;
    });
  }

  @override
  void dispose() {
    for (final controller in _fragmentControllers) {
      controller.dispose();
    }
    _titleController.dispose();
    _transcriptionController.dispose();
    _tagController.dispose();
    _recordingService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final transcript = await _recordingService.stopRecordingAndTranscribe();
      final path = _recordingService.latestRecordingPath;
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        if (path != null) {
          _audioPath = path;
        }
      });
      if (transcript != null && transcript.isNotEmpty && mounted) {
        _transcriptionController.text = transcript;
      }
      return;
    }

    await _recordingService.startRecording();
    if (!mounted) return;
    if (!_recordingService.isSupported) {
      setState(() {
        _voiceSupported = false;
        _mode = _CaptureMode.text;
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice capture is unavailable. You can type instead 💜'),
        ),
      );
      return;
    }
    setState(() {
      _isRecording = true;
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
    final resolvedAudioPath = _recordingService.latestRecordingPath ?? _audioPath;
    final entry = (widget.existingDream ?? DreamEntry(createdAt: DateTime.now())).copyWith(
      title: _titleController.text.trim(),
      transcription: _transcriptionController.text.trim(),
      fragments: fragments,
      emotions: _selectedEmotions.toList(),
      lucid: _lucid,
      nightmare: _nightmare,
      privatePreference: _private ? DreamPrivacyPreference.private : DreamPrivacyPreference.allowInsights,
      audioPath: resolvedAudioPath,
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
                        title: 'Choose your capture style',
                        subtitle: 'Switch between voice and typing whenever you need.',
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(18),
                        isSelected: [
                          _mode == _CaptureMode.voice,
                          _mode == _CaptureMode.text,
                        ],
                        onPressed: (index) {
                          if (index == 0 && !_voiceSupported) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voice capture isn’t supported here. You can type instead 💜'),
                              ),
                            );
                            return;
                          }
                          if (_isRecording) {
                            _toggleRecording();
                          }
                          setState(() {
                            _mode = _CaptureMode.values[index];
                          });
                        },
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Text('🎙 Voice capture'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Text('⌨️ Type manually'),
                          ),
                        ],
                      ),
                      if (!_voiceSupported)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.info_outline, size: 18, color: Colors.white70),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Voice capture isn’t supported on this device or browser. Your dreams can always be typed and saved safely.',
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (_mode == _CaptureMode.voice)
                  FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Voice capture',
                          subtitle: 'Tap to record before the details fade. I’ll drop the words into your story.',
                          padding: EdgeInsets.only(bottom: 12),
                        ),
                        _RecordingButton(
                          isRecording: _isRecording,
                          onTap: _voiceSupported ? _toggleRecording : null,
                        ),
                        if (_audioPath != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Audio saved locally at $_audioPath',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (_isRecording)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text('I’m listening. When you tap stop, the transcript appears below for editing.'),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text('Speak naturally. You can tidy the text once it appears in the story field.'),
                          ),
                      ],
                    ),
                  )
                else
                  FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SectionHeader(
                          title: 'Manual entry',
                          subtitle: 'Type your dream in the story field below. Fragments are enough.',
                          padding: EdgeInsets.only(bottom: 12),
                        ),
                        Text('Let your thoughts spill gently. Even short notes keep the memory alive.'),
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
                          onPressed: () => Navigator.of(context).pushNamed(
                            NightmareSupportScreen.routeName,
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
  const _RecordingButton({required this.isRecording, this.onTap});

  final bool isRecording;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: !enabled
                ? const [Color(0x2232479E), Color(0x11284784)]
                : isRecording
                    ? const [Color(0xFFED8070), Color(0xFFB53F4E)]
                    : const [Color(0x337B5CD6), Color(0x2232479E)],
          ),
          borderRadius: BorderRadius.circular(45),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRecording ? Icons.stop : Icons.mic,
              size: 36,
              color: enabled ? Colors.white : Colors.white54,
            ),
            const SizedBox(width: 12),
            Text(
              !enabled
                  ? 'Voice capture not available here'
                  : (isRecording ? 'Tap to finish recording' : 'Tap to record your voice'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: enabled ? Colors.white : Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
