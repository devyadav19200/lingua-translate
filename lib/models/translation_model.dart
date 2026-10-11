import 'dart:convert';
import 'package:uuid/uuid.dart';

class TranslationModel {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final String sourceLangName;
  final String targetLangName;
  final DateTime timestamp;
  bool isFavorite;

  TranslationModel({
    String? id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.sourceLangName,
    required this.targetLangName,
    DateTime? timestamp,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  TranslationModel copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    String? sourceLangName,
    String? targetLangName,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return TranslationModel(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      sourceLangName: sourceLangName ?? this.sourceLangName,
      targetLangName: targetLangName ?? this.targetLangName,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceText': sourceText,
        'translatedText': translatedText,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'sourceLangName': sourceLangName,
        'targetLangName': targetLangName,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      id: json['id'] as String,
      sourceText: json['sourceText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLang: json['sourceLang'] as String,
      targetLang: json['targetLang'] as String,
      sourceLangName: json['sourceLangName'] as String,
      targetLangName: json['targetLangName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory TranslationModel.fromJsonString(String jsonString) =>
      TranslationModel.fromJson(jsonDecode(jsonString));

  @override
  String toString() =>
      'TranslationModel(id: $id, $sourceLang→$targetLang: $sourceText → $translatedText)';
}
