import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';

/// A full news article: everything in [NewsEntity] plus its content.
class NewsDetailsEntity extends NewsEntity {
  const NewsDetailsEntity({
    required super.id,
    required super.slug,
    required super.title,
    super.date,
    super.thumbnailUrl,
    required super.excerpt,
    required super.webUrl,
    required this.contentHtml,
    required this.contentText,
  });

  /// The article as HTML (paragraphs, lists, line breaks).
  final String contentHtml;

  /// The same article as plain text.
  final String contentText;

  @override
  List<Object?> get props => [...super.props, contentHtml, contentText];
}
