import 'package:flutter/material.dart';

import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';

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
            title: const Text('Nightmare comfort'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: DreamBackground(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _step == 0 ? _calmScreen(context) : _journalScreen(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _calmScreen(BuildContext context) {
    return ListView(
      key: const ValueKey('calm'),
      children: [
        FrostedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You’re awake now. You’re safe.', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                'Nightmares often arrive when your mind is trying to process stress in a safe space. They have no power over you after you wake.',
              ),
            ],
          ),
        ),
        FrostedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Breathe with me', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              const Text(
                'Inhale for 4 gentle counts, hold for 2, exhale for 6. Feel the bed supporting you. Notice the weight of the blanket, the temperature of the room.',
              ),
              const SizedBox(height: 16),
              _BreathBar(),
            ],
          ),
        ),
        FrostedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Spiritual comfort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              Text(
                'Islamic tradition teaches that disturbing dreams are whispers meant only to upset you—they cannot harm you. Seek refuge in Allah, spit lightly to your left three times, and turn to your other side. You did nothing wrong by seeing this dream.',
              ),
            ],
          ),
        ),
        FrostedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Grounding ideas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              Text('• Sip water slowly and notice the temperature.\n• Place a hand on your heart and count 5 steady beats.\n• Name 5 things you can see, 4 you can feel, 3 you can hear.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
        FrostedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'This space is confidential. You did nothing wrong.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() => _step = 0),
                  ),
                ],
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
          ),
        ),
      ],
    );
  }
}

class _BreathBar extends StatefulWidget {
  @override
  State<_BreathBar> createState() => _BreathBarState();
}

class _BreathBarState extends State<_BreathBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value;
        double value;
        if (phase < 4 / 6) {
          value = phase / (4 / 6);
        } else if (phase < 5 / 6) {
          value = 1;
        } else {
          value = 1 - ((phase - 5 / 6) / (1 / 6));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 8),
            Text(
              value < 0.95
                  ? (value < 0.5 ? 'Inhale…' : 'Hold softly…')
                  : 'Exhale…',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
