enum ComfortLensPreference { science, islamic, both }

enum PrimaryGoal {
  improveRecall,
  sleepDeeper,
  learnLucid,
  healNightmares,
  spiritualComfort,
}

class UserPreferences {
  const UserPreferences({
    this.goals = const {},
    this.lensPreference = ComfortLensPreference.both,
    this.morningPromptEnabled = true,
    this.nightWindDownEnabled = true,
    this.realityCheckRemindersEnabled = false,
    this.hasCompletedOnboarding = false,
  });

  final Set<PrimaryGoal> goals;
  final ComfortLensPreference lensPreference;
  final bool morningPromptEnabled;
  final bool nightWindDownEnabled;
  final bool realityCheckRemindersEnabled;
  final bool hasCompletedOnboarding;

  UserPreferences copyWith({
    Set<PrimaryGoal>? goals,
    ComfortLensPreference? lensPreference,
    bool? morningPromptEnabled,
    bool? nightWindDownEnabled,
    bool? realityCheckRemindersEnabled,
    bool? hasCompletedOnboarding,
  }) {
    return UserPreferences(
      goals: goals ?? this.goals,
      lensPreference: lensPreference ?? this.lensPreference,
      morningPromptEnabled: morningPromptEnabled ?? this.morningPromptEnabled,
      nightWindDownEnabled: nightWindDownEnabled ?? this.nightWindDownEnabled,
      realityCheckRemindersEnabled:
          realityCheckRemindersEnabled ?? this.realityCheckRemindersEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() => {
        'goals': goals.map((e) => e.name).toList(),
        'lensPreference': lensPreference.name,
        'morningPromptEnabled': morningPromptEnabled,
        'nightWindDownEnabled': nightWindDownEnabled,
        'realityCheckRemindersEnabled': realityCheckRemindersEnabled,
        'hasCompletedOnboarding': hasCompletedOnboarding,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    final goalNames = (json['goals'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toSet();
    final goals = PrimaryGoal.values
        .where((goal) => goalNames.contains(goal.name))
        .toSet();
    return UserPreferences(
      goals: goals,
      lensPreference: ComfortLensPreference.values
          .firstWhere((element) => element.name == json['lensPreference'], orElse: () => ComfortLensPreference.both),
      morningPromptEnabled: json['morningPromptEnabled'] as bool? ?? true,
      nightWindDownEnabled: json['nightWindDownEnabled'] as bool? ?? true,
      realityCheckRemindersEnabled: json['realityCheckRemindersEnabled'] as bool? ?? false,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
    );
  }
}
