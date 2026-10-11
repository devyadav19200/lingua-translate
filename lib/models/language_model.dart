class LanguageModel {
  final String code;
  final String name;
  final String flag;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.flag,
  });

  factory LanguageModel.fromMap(Map<String, String> map) {
    return LanguageModel(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      flag: map['flag'] ?? '🌐',
    );
  }

  Map<String, String> toMap() => {
        'code': code,
        'name': name,
        'flag': flag,
      };

  bool get isAutoDetect => code == 'auto';

  String get displayName => '$flag $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'LanguageModel(code: $code, name: $name)';
}
