import 'package:dio/dio.dart';

/// The files at [paths] as [FormData] entries under [key] (e.g.
/// `attachments[]`), each with the content type its extension names.
Future<List<MapEntry<String, MultipartFile>>> multipartFiles(
  String key,
  List<String> paths,
) async => [
  for (final path in paths)
    MapEntry(
      key,
      await MultipartFile.fromFile(
        path,
        contentType: MultipartFile.lookupMediaType(path),
      ),
    ),
];
