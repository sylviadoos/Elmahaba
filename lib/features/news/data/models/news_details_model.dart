import 'package:al_mahhaba_school/features/news/domain/entities/news_details_entity.dart';

class NewsDetailsModel extends NewsDetailsEntity {
  const NewsDetailsModel({
    required super.id,
    required super.slug,
    required super.title,
    super.date,
    super.thumbnailUrl,
    required super.excerpt,
    required super.webUrl,
    required super.contentHtml,
    required super.contentText,
  });

  factory NewsDetailsModel.fromJson(Map<String, dynamic> json) =>
      NewsDetailsModel(
        id: json['id'] as String,
        slug: json['slug'] as String,
        title: json['title'] as String,
        date: DateTime.tryParse(json['date'] as String? ?? ''),
        thumbnailUrl: json['thumbnail_url'] as String?,
        excerpt: json['excerpt'] as String? ?? '',
        webUrl: json['web_url'] as String,
        contentHtml: json['content_html'] as String? ?? '',
        contentText: json['content_text'] as String? ?? '',
      );
}
