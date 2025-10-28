import 'package:flutter/material.dart';

import '../../models/dream_entry.dart';

class FeelingsOnlyDialog extends StatefulWidget {
  const FeelingsOnlyDialog({super.key});

  @override
  State<FeelingsOnlyDialog> createState() => _FeelingsOnlyDialogState();
}

class _FeelingsOnlyDialogState extends State<FeelingsOnlyDialog> {
  final _selectedEmotions = <DreamEmotion>{};
  final _noteController = TextEditingController();
  final _suggestions = const [
    'Grateful for small kindness',
    'Lingering worry from the day',
    'Sense of protection',
    'Still figuring out the feeling',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text('How did the dream feel?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Describe it in a sentence',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _suggestions
                  .map(
                    (suggestion) => ActionChip(
                      label: Text(suggestion),
                      onPressed: () {
                        setState(() {
                          _noteController.text = suggestion;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedEmotions.isEmpty) {
              _selectedEmotions.add(DreamEmotion.other);
            }
            final entry = DreamEntry(
              createdAt: DateTime.now(),
              emotions: _selectedEmotions.toList(),
              fragments: [
                DreamFragmentField(
                  label: 'Emotions',
                  value: _selectedEmotions.map((emotion) => emotion.label).join(', '),
                ),
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
