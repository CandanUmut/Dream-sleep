import 'package:flutter/foundation.dart';

import '../models/dream_entry.dart';
import '../models/morning_reflection.dart';
import '../models/night_note.dart';
import '../models/user_preferences.dart';
import '../services/storage/local_storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({LocalStorageService? storage}) : _storage = storage ?? LocalStorageService.instance;

  final LocalStorageService _storage;

  static const _dreamsKey = 'dreams';
  static const _reflectionsKey = 'reflections';
  static const _preferencesKey = 'preferences';
  static const _nightNotesKey = 'night_notes';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<DreamEntry> _dreams = [];
  List<DreamEntry> get dreams => List.unmodifiable(_dreams);

  List<MorningReflection> _reflections = [];
  List<MorningReflection> get reflections => List.unmodifiable(_reflections);

  UserPreferences _preferences = const UserPreferences();
  UserPreferences get preferences => _preferences;

  List<NightNote> _nightNotes = [];
  List<NightNote> get nightNotes => List.unmodifiable(_nightNotes);

  NightNote? get latestNightNote => latestNightNoteFor('winddown');

  NightNote? latestNightNoteFor(String category) {
    for (final note in _nightNotes) {
      if (note.category == category) {
        return note;
      }
    }
    return null;
  }

  int get feelingsOnlyCount => _dreams.where((dream) => dream.onlyFeelingsLog).length;

  int get dreamsLoggedThisWeek {
    if (_dreams.isEmpty) return 0;
    final now = DateTime.now();
    final startOfWindow = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    return _dreams
        .where((dream) => dream.createdAt.isAfter(startOfWindow) || dream.createdAt.isAtSameMomentAs(startOfWindow))
        .length;
  }

  int get recallStreak {
    if (_dreams.isEmpty) return 0;
    final uniqueDates = _dreams
        .map((dream) => DateTime(dream.createdAt.year, dream.createdAt.month, dream.createdAt.day))
        .toSet()
        .toList()
      ..sort();
    if (uniqueDates.isEmpty) return 0;
    var streak = 1;
    for (var i = uniqueDates.length - 1; i > 0; i--) {
      final current = uniqueDates[i];
      final previous = uniqueDates[i - 1];
      if (current.difference(previous).inDays == 1) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }

  Map<String, int> get tagCounts {
    final counts = <String, int>{};
    for (final dream in analyzableDreams) {
      for (final tag in dream.tags.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty)) {
        counts.update(tag, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  Map<RestfulnessLevel, int> get restfulnessSummary {
    final counts = <RestfulnessLevel, int>{};
    for (final reflection in _reflections) {
      counts.update(reflection.restfulness, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Map<NightWakeFrequency, int> get nightWakeSummary {
    final counts = <NightWakeFrequency, int>{};
    for (final reflection in _reflections) {
      counts.update(reflection.wakeFrequency, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  double get nightmareRatio => _dreams.isEmpty ? 0 : nightmareCount / _dreams.length;

  double get positiveEmotionRatio {
    if (analyzableDreams.isEmpty) return 0;
    final calmingEmotions = {
      DreamEmotion.calm,
      DreamEmotion.joyful,
      DreamEmotion.relieved,
    };
    final totalEmotions = analyzableDreams.fold<int>(0, (count, dream) => count + dream.emotions.length);
    if (totalEmotions == 0) return 0;
    final positive = analyzableDreams.fold<int>(0, (count, dream) {
      final matches = dream.emotions.where(calmingEmotions.contains).length;
      return count + matches;
    });
    return positive / totalEmotions;
  }

  Future<void> load() async {
    if (_isInitialized) return;
    final dreamMaps = await _storage.readCollection(_dreamsKey);
    _dreams = dreamMaps.map(DreamEntry.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final reflectionMaps = await _storage.readCollection(_reflectionsKey);
    _reflections = reflectionMaps.map(MorningReflection.fromJson).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final preferenceMaps = await _storage.readCollection(_preferencesKey);
    if (preferenceMaps.isNotEmpty) {
      _preferences = UserPreferences.fromJson(preferenceMaps.first);
    }

    final nightNoteMaps = await _storage.readCollection(_nightNotesKey);
    _nightNotes = nightNoteMaps.map(NightNote.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> upsertDream(DreamEntry entry) async {
    final index = _dreams.indexWhere((element) => element.id == entry.id);
    if (index >= 0) {
      _dreams[index] = entry.copyWith(updatedAt: DateTime.now());
    } else {
      _dreams.add(entry);
    }
    _dreams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _storage.writeCollection(
      _dreamsKey,
      _dreams.map((e) => e.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> deleteDream(String id) async {
    _dreams.removeWhere((element) => element.id == id);
    await _storage.writeCollection(
      _dreamsKey,
      _dreams.map((e) => e.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> upsertReflection(MorningReflection reflection) async {
    final index = _reflections.indexWhere((element) => element.id == reflection.id);
    if (index >= 0) {
      _reflections[index] = reflection;
    } else {
      _reflections.add(reflection);
    }
    _reflections.sort((a, b) => b.date.compareTo(a.date));
    await _storage.writeCollection(
      _reflectionsKey,
      _reflections.map((e) => e.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    _preferences = preferences;
    await _storage.writeCollection(_preferencesKey, [preferences.toJson()]);
    notifyListeners();
  }

  Future<void> addNightNote(NightNote note) async {
    _nightNotes.add(note);
    _nightNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _storage.writeCollection(
      _nightNotesKey,
      _nightNotes.map((note) => note.toJson()).toList(),
    );
    notifyListeners();
  }

  List<DreamEntry> get analyzableDreams =>
      _dreams.where((dream) => dream.privatePreference == DreamPrivacyPreference.allowInsights).toList();

  Map<String, int> get recurringPeopleCounts {
    final counts = <String, int>{};
    for (final dream in analyzableDreams) {
      for (final fragment in dream.fragments.where((fragment) => fragment.label == 'People/Characters')) {
        final people = fragment.value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final person in people) {
          counts.update(person, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }
    return counts;
  }

  Map<DreamEmotion, int> get emotionFrequency {
    final counts = <DreamEmotion, int>{};
    for (final dream in analyzableDreams) {
      for (final emotion in dream.emotions) {
        counts.update(emotion, (value) => value + 1, ifAbsent: () => 1);
      }
      if (dream.morningMood != null) {
        counts.update(dream.morningMood!, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  int get lucidDreamCount => analyzableDreams.where((dream) => dream.lucid).length;
  int get nightmareCount => dreams.where((dream) => dream.nightmare).length;

  Future<void> reset() async {
    _dreams = [];
    _reflections = [];
    _preferences = const UserPreferences();
    _nightNotes = [];
    await _storage.clear(_dreamsKey);
    await _storage.clear(_reflectionsKey);
    await _storage.clear(_preferencesKey);
    await _storage.clear(_nightNotesKey);
    notifyListeners();
  }
}
