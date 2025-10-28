import 'package:flutter/foundation.dart';

import '../models/dream_entry.dart';
import '../models/morning_reflection.dart';
import '../models/user_preferences.dart';
import '../services/storage/local_storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({LocalStorageService? storage}) : _storage = storage ?? LocalStorageService.instance;

  final LocalStorageService _storage;

  static const _dreamsKey = 'dreams';
  static const _reflectionsKey = 'reflections';
  static const _preferencesKey = 'preferences';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<DreamEntry> _dreams = [];
  List<DreamEntry> get dreams => List.unmodifiable(_dreams);

  List<MorningReflection> _reflections = [];
  List<MorningReflection> get reflections => List.unmodifiable(_reflections);

  UserPreferences _preferences = const UserPreferences();
  UserPreferences get preferences => _preferences;

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
    await _storage.clear(_dreamsKey);
    await _storage.clear(_reflectionsKey);
    await _storage.clear(_preferencesKey);
    notifyListeners();
  }
}
