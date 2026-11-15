import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Stand-ins for the pages a page under test opens: each shows its path,
/// and the `extra` it was opened with goes in [extras], keyed by path.
List<GoRoute> stubRoutes(
  Iterable<String> paths, {
  Map<String, Object?>? extras,
}) => [
  for (final path in paths)
    GoRoute(
      path: path,
      builder: (_, state) {
        extras?[path] = state.extra;
        return Scaffold(body: Text(path));
      },
    ),
];
