import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../home/home_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _index = 0;
  Set<PrimaryGoal> _goals = {};
  ComfortLensPreference _lensPreference = ComfortLensPreference.both;
  bool _morningPromptEnabled = true;
  bool _nightWindDownEnabled = true;

  void _next() {
    if (_index < _pages.length - 1) {
      setState(() {
        _index += 1;
      });
    } else {
      _completeOnboarding();
    }
  }

  void _back() {
    if (_index == 0) return;
    setState(() {
      _index -= 1;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = UserPreferences(
      goals: _goals,
      lensPreference: _lensPreference,
      morningPromptEnabled: _morningPromptEnabled,
      nightWindDownEnabled: _nightWindDownEnabled,
      hasCompletedOnboarding: true,
    );
    await context.read<AppState>().updatePreferences(prefs);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  List<Widget> get _pages => [
        _WelcomePage(onContinue: _next),
        _GoalsPage(
          selectedGoals: _goals,
          onGoalToggle: (goal) {
            setState(() {
              if (_goals.contains(goal)) {
                _goals.remove(goal);
              } else {
                _goals.add(goal);
              }
            });
          },
          onNext: _next,
          onBack: _back,
        ),
        _LensPage(
          lensPreference: _lensPreference,
          onChanged: (lens) {
            setState(() => _lensPreference = lens);
          },
          onNext: _next,
          onBack: _back,
        ),
        _PrivacyPage(onNext: _next, onBack: _back),
        _MorningPromptPage(
          enabled: _morningPromptEnabled,
          onChanged: (value) => setState(() => _morningPromptEnabled = value),
          onNext: _next,
          onBack: _back,
        ),
        _NightRoutinePage(
          enabled: _nightWindDownEnabled,
          onChanged: (value) => setState(() => _nightWindDownEnabled = value),
          onNext: _next,
          onBack: _back,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: pages[_index],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            "Hi, I'm here to sit with you at night.\nI'll help you remember your dreams,\nsleep more peacefully,\nand feel safer in your own mind.\nYour dreams stay private.",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _GoalsPage extends StatelessWidget {
  const _GoalsPage({
    required this.selectedGoals,
    required this.onGoalToggle,
    required this.onNext,
    required this.onBack,
  });

  final Set<PrimaryGoal> selectedGoals;
  final ValueChanged<PrimaryGoal> onGoalToggle;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final options = {
      PrimaryGoal.improveRecall: 'Remember my dreams better',
      PrimaryGoal.sleepDeeper: 'Sleep deeper and wake calmer',
      PrimaryGoal.learnLucid: 'Learn lucid dreaming',
      PrimaryGoal.healNightmares: 'Heal from nightmares / feel safe at night',
      PrimaryGoal.spiritualComfort: 'Spiritual / Islamic comfort at night',
    };
    return _ScaffoldedPage(
      title: 'What do you want most?',
      children: [
        for (final entry in options.entries)
          CheckboxListTile(
            title: Text(entry.value),
            value: selectedGoals.contains(entry.key),
            onChanged: (_) => onGoalToggle(entry.key),
          ),
      ],
      onNext: onNext,
      onBack: onBack,
    );
  }
}

class _LensPage extends StatelessWidget {
  const _LensPage({
    required this.lensPreference,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  final ComfortLensPreference lensPreference;
  final ValueChanged<ComfortLensPreference> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _ScaffoldedPage(
      title: 'Which comfort style feels right for you?',
      children: [
        RadioListTile(
          title: const Text('Science / psychology guidance'),
          value: ComfortLensPreference.science,
          groupValue: lensPreference,
          onChanged: (ComfortLensPreference? value) {
            if (value != null) onChanged(value);
          },
        ),
        RadioListTile(
          title: const Text('Islamic spiritual comfort'),
          value: ComfortLensPreference.islamic,
          groupValue: lensPreference,
          onChanged: (ComfortLensPreference? value) {
            if (value != null) onChanged(value);
          },
        ),
        RadioListTile(
          title: const Text('Both'),
          value: ComfortLensPreference.both,
          groupValue: lensPreference,
          onChanged: (ComfortLensPreference? value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
      onNext: onNext,
      onBack: onBack,
    );
  }
}

class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage({required this.onNext, required this.onBack});

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _ScaffoldedPage(
      title: 'Privacy Promise',
      description:
          'Your dreams are yours. We store them on this device. We will never sell them. You choose what can be analyzed and what stays secret. You are safe here.',
      onNext: onNext,
      onBack: onBack,
    );
  }
}

class _MorningPromptPage extends StatelessWidget {
  const _MorningPromptPage({
    required this.enabled,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _ScaffoldedPage(
      title: 'Morning habit',
      description:
          'Would you like a gentle “Did you dream?” prompt each morning? Logging even “no dream” keeps the recall muscle alive.',
      children: [
        SwitchListTile(
          value: enabled,
          title: const Text('Morning prompt'),
          onChanged: onChanged,
        ),
      ],
      onNext: onNext,
      onBack: onBack,
    );
  }
}

class _NightRoutinePage extends StatelessWidget {
  const _NightRoutinePage({
    required this.enabled,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _ScaffoldedPage(
      title: 'Night wind-down',
      description:
          'At night I’ll help you wind down in under 2 minutes: dim the mind, set an intention (“I will remember my dreams”), and rest with protection. Ready?',
      children: [
        SwitchListTile(
          value: enabled,
          title: const Text('Night wind-down guidance'),
          onChanged: onChanged,
        ),
      ],
      onNext: onNext,
      onBack: onBack,
      nextLabel: 'Begin',
    );
  }
}

class _ScaffoldedPage extends StatelessWidget {
  const _ScaffoldedPage({
    required this.title,
    this.description,
    this.children = const [],
    required this.onNext,
    required this.onBack,
    this.nextLabel = 'Next',
  });

  final String title;
  final String? description;
  final List<Widget> children;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  ...children,
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onNext,
                child: Text(nextLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
