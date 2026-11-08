/// A number the API may send as a number or as text ("297.4"); null when
/// it's missing or not a number.
double? jsonDouble(Object? value) => switch (value) {
  final num number => number.toDouble(),
  final String text => double.tryParse(text.trim()),
  _ => null,
};

/// Text the API broke onto lines, joined back: "Multi-\ndisciplinary" →
/// "Multi-disciplinary"; empty when it's missing.
String jsonText(Object? value) => switch (value) {
  final String text => text.replaceAll('-\n', '-').replaceAll('\n', ' ').trim(),
  _ => '',
};

/// [jsonText], or null when there's none; a number as text ("1042").
String? jsonTextOrNull(Object? value) {
  final text = value is num ? value.toString() : jsonText(value);
  return text.isEmpty ? null : text;
}

/// The objects in a JSON list; empty when it's missing or not a list.
List<Map<String, dynamic>> jsonObjects(Object? value) => [
  if (value is List)
    for (final item in value)
      if (item is Map<String, dynamic>) item,
];
