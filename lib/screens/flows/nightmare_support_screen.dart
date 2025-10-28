import 'package:flutter/material.dart';

class NightmareSupportScreen extends StatefulWidget {
  const NightmareSupportScreen({super.key});

  @override
  State<NightmareSupportScreen> createState() => _NightmareSupportScreenState();
}

class _NightmareSupportScreenState extends State<NightmareSupportScreen> {
  int _step = 0;
  final _descriptionController = TextEditingController();
  final _bodyFeelingController = TextEditingController();
  final _reframeController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _bodyFeelingController.dispose();
    _reframeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nightmare comfort'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _step == 0 ? _calmScreen(context) : _journalScreen(context),
        ),
      ),
    );
  }

  Widget _calmScreen(BuildContext context) {
    return ListView(
      key: const ValueKey('calm'),
      children: [
        Text('You’re awake now. You’re safe.', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text(
          'Nightmares often arrive when your mind is trying to process stress in a safe space. They have no power over you after you wake.',
        ),
        const SizedBox(height: 24),
        _GroundingCard(
          title: 'Breathe with me',
          body: 'Inhale for 4 gentle counts, hold for 2, exhale for 6. Feel the bed supporting you. Notice the weight of the blanket, the temperature of the room.',
        ),
        _GroundingCard(
          title: 'Spiritual comfort',
          body:
              'Islamic tradition teaches that disturbing dreams are whispers meant only to upset you—they cannot harm you. Seek refuge in Allah, spit lightly to your left three times, and turn to your other side. You did nothing wrong by seeing this dream.',
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _step = 1),
          child: const Text('I want to talk about it'),
        ),
      ],
    );
  }

  Widget _journalScreen(BuildContext context) {
    return ListView(
      key: const ValueKey('journal'),
      children: [
        Text(
          'This space is confidential. You did nothing wrong.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'What happened in the nightmare?',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bodyFeelingController,
          decoration: const InputDecoration(
            labelText: 'How does your body feel right now?',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reframeController,
          decoration: const InputDecoration(
            labelText: 'Rewrite the ending in a safer way (optional)',
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'If nightmares are frequent, violent, or keep you from sleeping, please talk with a licensed mental health professional. You deserve support.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Save and rest'),
        ),
      ],
    );
  }
}

class _GroundingCard extends StatelessWidget {
  const _GroundingCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(body),
          ],
        ),
      ),
    );
  }
}
