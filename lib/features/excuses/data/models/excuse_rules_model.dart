import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_rules_entity.dart';

class ExcuseRulesModel extends ExcuseRulesEntity {
  const ExcuseRulesModel({
    required super.windowDays,
    required super.maxDocuments,
    required super.allowedTypes,
    required super.maxFileMegabytes,
  });

  /// { "window_days": 3, "max_documents": 5,
  ///   "allowed_types": ["jpg", "png", "pdf"], "max_file_mb": 10 }; the
  /// documented values for what's left out.
  factory ExcuseRulesModel.fromJson(Map<String, dynamic> json) {
    const defaults = ExcuseRulesEntity.defaults;
    final types = json['allowed_types'];
    return ExcuseRulesModel(
      windowDays: json['window_days'] as int? ?? defaults.windowDays,
      maxDocuments: json['max_documents'] as int? ?? defaults.maxDocuments,
      allowedTypes: types is List && types.isNotEmpty
          ? [
              for (final type in types)
                if (type is String) type.toLowerCase(),
            ]
          : defaults.allowedTypes,
      maxFileMegabytes:
          json['max_file_mb'] as int? ?? defaults.maxFileMegabytes,
    );
  }
}
