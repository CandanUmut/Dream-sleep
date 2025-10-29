import 'dart:convert';

import 'package:uuid/uuid.dart';

class NightNote {
  NightNote({
    String? id,
    required this.createdAt,
    required this.text,
    this.category = 'winddown',
  }) : id = id ?? const Uuid().v4();

  final String id;
  final DateTime createdAt;
  final String text;
  final String category;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'text': text,
        'category': category,
      };

  factory NightNote.fromJson(Map<String, dynamic> json) => NightNote(
        id: json['id'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        text: json['text'] as String? ?? '',
        category: json['category'] as String? ?? 'winddown',
      );

  String toRawJson() => jsonEncode(toJson());

  factory NightNote.fromRawJson(String source) =>
      NightNote.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
