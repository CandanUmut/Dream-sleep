import 'package:flutter/material.dart';

import '../../models/dream_entry.dart';

class FeelingsOnlyDialog extends StatefulWidget {
  const FeelingsOnlyDialog({super.key});

  @override
  State<FeelingsOnlyDialog> createState() => _FeelingsOnlyDialogState();
}

class _FeelingsOnlyDialogState extends State<FeelingsOnlyDialog> {
  DreamEmotion? _emotion = DreamEmotion.other;
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text('How did the dream feel?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<DreamEmotion>(
            value: _emotion,
            items: DreamEmotion.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.label),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _emotion = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'One line note',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_emotion == null) return;
            final entry = DreamEntry(
              createdAt: DateTime.now(),
              emotions: [_emotion!],
              fragments: [
                DreamFragmentField(label: 'Emotions', value: _emotion!.label),
                DreamFragmentField(label: 'Notes', value: _noteController.text.trim()),
              ],
              onlyFeelingsLog: true,
            );
            Navigator.of(context).pop(entry);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
