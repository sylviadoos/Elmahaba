import 'package:equatable/equatable.dart';

/// A school news post, as the app uses it.
class NewsEntity extends Equatable {
  const NewsEntity({
    required this.id,
    required this.slug,
    required this.title,
    this.date,
    this.thumbnailUrl,
    required this.excerpt,
    required this.webUrl,
  });

  final String id;

  /// e.g. "important-notice-for-online-applicants"
  final String slug;
  final String title;

  /// `null` when the API sends no date or an invalid one.
  final DateTime? date;

  /// Full URL of the cover photo; `null` for news without one.
  final String? thumbnailUrl;

  /// Start of the article, already cut by the API and ending in "...".
  final String excerpt;

  /// The full article on the school website.
  final String webUrl;

  @override
  List<Object?> get props => [
    id,
    slug,
    title,
    date,
    thumbnailUrl,
    excerpt,
    webUrl,
  ];
}
