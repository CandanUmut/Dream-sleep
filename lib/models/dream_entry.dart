import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum DreamPrivacyPreference { private, allowInsights }

enum DreamEmotion {
  calm,
  joyful,
  longing,
  anxious,
  stressed,
  afraid,
  overwhelmed,
  relieved,
  other,
}

extension DreamEmotionDisplay on DreamEmotion {
  String get label {
    switch (this) {
      case DreamEmotion.calm:
        return 'Calm';
      case DreamEmotion.joyful:
        return 'Joyful';
      case DreamEmotion.longing:
        return 'Longing';
      case DreamEmotion.anxious:
        return 'Anxious';
      case DreamEmotion.stressed:
        return 'Stressed';
      case DreamEmotion.afraid:
        return 'Afraid';
      case DreamEmotion.overwhelmed:
        return 'Overwhelmed';
      case DreamEmotion.relieved:
        return 'Relieved';
      case DreamEmotion.other:
        return 'Other';
    }
  }
}

class DreamFragmentField {
  DreamFragmentField({
    required this.label,
    this.value = '',
  });

  final String label;
  final String value;

  DreamFragmentField copyWith({String? value}) =>
      DreamFragmentField(label: label, value: value ?? this.value);

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  factory DreamFragmentField.fromJson(Map<String, dynamic> json) =>
      DreamFragmentField(label: json['label'] as String, value: json['value'] as String? ?? '');
}

class DreamEntry {
  DreamEntry({
    String? id,
    required this.createdAt,
    this.updatedAt,
    this.audioPath,
    this.transcription = '',
    this.title = '',
    this.fragments = const [],
    this.emotions = const [],
    this.tags = const <String>[],
    this.lucid = false,
    this.nightmare = false,
    this.privatePreference = DreamPrivacyPreference.private,
    this.morningMood,
    this.onlyFeelingsLog = false,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? audioPath;
  final String transcription;
  final String title;
  final List<DreamFragmentField> fragments;
  final List<DreamEmotion> emotions;
  final List<String> tags;
  final bool lucid;
  final bool nightmare;
  final DreamPrivacyPreference privatePreference;
  final DreamEmotion? morningMood;
  final bool onlyFeelingsLog;

  DreamEntry copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? audioPath,
    String? transcription,
    String? title,
    List<DreamFragmentField>? fragments,
    List<DreamEmotion>? emotions,
    List<String>? tags,
    bool? lucid,
    bool? nightmare,
    DreamPrivacyPreference? privatePreference,
    DreamEmotion? morningMood,
    bool? onlyFeelingsLog,
  }) {
    return DreamEntry(
      id: id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      audioPath: audioPath ?? this.audioPath,
      transcription: transcription ?? this.transcription,
      title: title ?? this.title,
      fragments: fragments ?? this.fragments,
      emotions: emotions ?? this.emotions,
      tags: tags ?? this.tags,
      lucid: lucid ?? this.lucid,
      nightmare: nightmare ?? this.nightmare,
      privatePreference: privatePreference ?? this.privatePreference,
      morningMood: morningMood ?? this.morningMood,
      onlyFeelingsLog: onlyFeelingsLog ?? this.onlyFeelingsLog,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'audioPath': audioPath,
        'transcription': transcription,
        'title': title,
        'fragments': fragments.map((f) => f.toJson()).toList(),
        'emotions': emotions.map((e) => e.name).toList(),
        'tags': tags,
        'lucid': lucid,
        'nightmare': nightmare,
        'privatePreference': privatePreference.name,
        'morningMood': morningMood?.name,
        'onlyFeelingsLog': onlyFeelingsLog,
      };

  factory DreamEntry.fromJson(Map<String, dynamic> json) {
    return DreamEntry(
      id: json['id'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      audioPath: json['audioPath'] as String?,
      transcription: json['transcription'] as String? ?? '',
      title: json['title'] as String? ?? '',
      fragments: (json['fragments'] as List<dynamic>? ?? [])
          .map((e) => DreamFragmentField.fromJson(e as Map<String, dynamic>))
          .toList(),
      emotions: (json['emotions'] as List<dynamic>? ?? [])
          .map((e) => DreamEmotion.values.firstWhereOrNull((element) => element.name == e) ?? DreamEmotion.other)
          .whereNotNull()
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      lucid: json['lucid'] as bool? ?? false,
      nightmare: json['nightmare'] as bool? ?? false,
      privatePreference: DreamPrivacyPreference.values
              .firstWhereOrNull((element) => element.name == json['privatePreference']) ??
          DreamPrivacyPreference.private,
      morningMood: (json['morningMood'] as String?) != null
          ? DreamEmotion.values
              .firstWhereOrNull((element) => element.name == json['morningMood'])
          : null,
      onlyFeelingsLog: json['onlyFeelingsLog'] as bool? ?? false,
    );
  }

  String get formattedDate => DateFormat.yMMMMd().add_jm().format(createdAt);

  bool get isPrivate => privatePreference == DreamPrivacyPreference.private;

  String toRawJson() => jsonEncode(toJson());

  factory DreamEntry.fromRawJson(String source) =>
      DreamEntry.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
