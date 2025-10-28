import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/dream_background.dart';
import '../../widgets/frosted_card.dart';
import '../../widgets/section_header.dart';
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

  static const _pageCount = 6;

  void _next() {
    if (_index < _pageCount - 1) {
      setState(() => _index += 1);
    } else {
      _completeOnboarding();
    }
  }

  void _back() {
    if (_index == 0) return;
    setState(() => _index -= 1);
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

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / _pageCount;
    return Stack(
      children: [
        DreamBackground(
          useSafeArea: false,
          child: const SizedBox.expand(),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: DreamBackground(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildPage(progress),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(double progress) {
    switch (_index) {
      case 0:
        return _WelcomePage(
          onContinue: _next,
          progress: progress,
          step: _index + 1,
          totalSteps: _pageCount,
        );
      case 1:
        return _GoalsPage(
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
          progress: progress,
          step: _index + 1,
          totalSteps: _pageCount,
        );
      case 2:
        return _LensPage(
          lensPreference: _lensPreference,
          onChanged: (lens) => setState(() => _lensPreference = lens),
          onNext: _next,
          onBack: _back,
          progress: progress,
          step: _index + 1,
          totalSteps: _pageCount,
        );
      case 3:
        return _PrivacyPage(
          onNext: _next,
          onBack: _back,
          progress: progress,
          step: _index + 1,
          totalSteps: _pageCount,
        );
      case 4:
        return _MorningPromptPage(
          enabled: _morningPromptEnabled,
          onChanged: (value) => setState(() => _morningPromptEnabled = value),
          onNext: _next,
          onBack: _back,
          progress: progress,
          step: _index + 1,
          totalSteps: _pageCount,
        );
      case 5:
        return _NightRoutinePage(
          enabled: _nightWindDownEnabled,
          onChanged: (value) => setState(() => _nightWindDownEnabled = value),
          onNext: _next,
          onBack: _back,
          progress: progress,
          step: _index + 1,
          totalSteps: _pageCount,
          nextLabel: 'Begin',
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.onContinue,
    required this.progress,
    required this.step,
    required this.totalSteps,
  });

  final VoidCallback onContinue;
  final double progress;
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OnboardingProgress(progress: progress, step: step, totalSteps: totalSteps),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, I'm here to sit with you at night.",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "I'll help you remember your dreams, sleep more peacefully, and feel safer in your own mind. Your dreams stay private.",
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: onContinue,
                        child: const Text('Let’s begin'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalsPage extends StatelessWidget {
  const _GoalsPage({
    required this.selectedGoals,
    required this.onGoalToggle,
    required this.onNext,
    required this.onBack,
    required this.progress,
    required this.step,
    required this.totalSteps,
  });

  final Set<PrimaryGoal> selectedGoals;
  final ValueChanged<PrimaryGoal> onGoalToggle;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final double progress;
  final int step;
  final int totalSteps;

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
      description: 'Choose one or more focuses. You can change them later.',
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
      progress: progress,
      step: step,
      totalSteps: totalSteps,
    );
  }
}

class _LensPage extends StatelessWidget {
  const _LensPage({
    required this.lensPreference,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
    required this.progress,
    required this.step,
    required this.totalSteps,
  });

  final ComfortLensPreference lensPreference;
  final ValueChanged<ComfortLensPreference> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final double progress;
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return _ScaffoldedPage(
      title: 'Which comfort style feels right for you?',
      description: 'I can offer science guidance, Islamic reassurance, or a blend.',
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
      progress: progress,
      step: step,
      totalSteps: totalSteps,
    );
  }
}

class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage({
    required this.onNext,
    required this.onBack,
    required this.progress,
    required this.step,
    required this.totalSteps,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final double progress;
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return _ScaffoldedPage(
      title: 'Privacy Promise',
      description:
          'Your dreams are yours. They stay on this device unless you choose to share. You control what can be analyzed and what stays sacred.',
      onNext: onNext,
      onBack: onBack,
      progress: progress,
      step: step,
      totalSteps: totalSteps,
    );
  }
}

class _MorningPromptPage extends StatelessWidget {
  const _MorningPromptPage({
    required this.enabled,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
    required this.progress,
    required this.step,
    required this.totalSteps,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final double progress;
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return _ScaffoldedPage(
      title: 'Morning habit',
      description: 'A gentle “Did you dream?” prompt keeps recall alive even on quiet mornings.',
      children: [
        SwitchListTile(
          value: enabled,
          title: const Text('Morning prompt'),
          onChanged: onChanged,
        ),
      ],
      onNext: onNext,
      onBack: onBack,
      progress: progress,
      step: step,
      totalSteps: totalSteps,
    );
  }
}

class _NightRoutinePage extends StatelessWidget {
  const _NightRoutinePage({
    required this.enabled,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
    required this.progress,
    required this.step,
    required this.totalSteps,
    this.nextLabel = 'Next',
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final double progress;
  final int step;
  final int totalSteps;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return _ScaffoldedPage(
      title: 'Night wind-down',
      description: 'I can guide a two-minute wind-down: dim the mind, set intention, and rest with protection. Ready?',
      children: [
        SwitchListTile(
          value: enabled,
          title: const Text('Night wind-down guidance'),
          onChanged: onChanged,
        ),
      ],
      onNext: onNext,
      onBack: onBack,
      nextLabel: nextLabel,
      progress: progress,
      step: step,
      totalSteps: totalSteps,
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
    required this.progress,
    required this.step,
    required this.totalSteps,
  });

  final String title;
  final String? description;
  final List<Widget> children;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String nextLabel;
  final double progress;
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OnboardingProgress(progress: progress, step: step, totalSteps: totalSteps),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: SectionHeader(
                            title: title,
                            subtitle: description,
                            padding: const EdgeInsets.only(bottom: 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...children,
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
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingProgress extends StatelessWidget {
  const _OnboardingProgress({required this.progress, required this.step, required this.totalSteps});

  final double progress;
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text('Step $step of $totalSteps', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
