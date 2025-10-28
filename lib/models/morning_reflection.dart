import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum RestfulnessLevel { rested, okay, drained }

enum NightWakeFrequency { none, once, multiple }

class MorningReflection {
  MorningReflection({
    String? id,
    required this.date,
    this.restfulness = RestfulnessLevel.okay,
    this.wakeFrequency = NightWakeFrequency.none,
    this.bedtime,
    this.waketime,
    this.notes = '',
  }) : id = id ?? const Uuid().v4();

  final String id;
  final DateTime date;
  final RestfulnessLevel restfulness;
  final NightWakeFrequency wakeFrequency;
  final DateTime? bedtime;
  final DateTime? waketime;
  final String notes;

  MorningReflection copyWith({
    DateTime? date,
    RestfulnessLevel? restfulness,
    NightWakeFrequency? wakeFrequency,
    DateTime? bedtime,
    DateTime? waketime,
    String? notes,
  }) {
    return MorningReflection(
      id: id,
      date: date ?? this.date,
      restfulness: restfulness ?? this.restfulness,
      wakeFrequency: wakeFrequency ?? this.wakeFrequency,
      bedtime: bedtime ?? this.bedtime,
      waketime: waketime ?? this.waketime,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'restfulness': restfulness.name,
        'wakeFrequency': wakeFrequency.name,
        'bedtime': bedtime?.toIso8601String(),
        'waketime': waketime?.toIso8601String(),
        'notes': notes,
      };

  factory MorningReflection.fromJson(Map<String, dynamic> json) => MorningReflection(
        id: json['id'] as String?,
        date: DateTime.parse(json['date'] as String),
        restfulness: RestfulnessLevel.values
            .firstWhere((element) => element.name == json['restfulness']),
        wakeFrequency: NightWakeFrequency.values
            .firstWhere((element) => element.name == json['wakeFrequency']),
        bedtime: json['bedtime'] != null ? DateTime.tryParse(json['bedtime'] as String) : null,
        waketime: json['waketime'] != null ? DateTime.tryParse(json['waketime'] as String) : null,
        notes: json['notes'] as String? ?? '',
      );

  String get formattedDate => DateFormat.yMMMMd().format(date);
}
