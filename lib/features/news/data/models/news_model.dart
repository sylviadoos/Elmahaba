import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';

class NewsModel extends NewsEntity {
  const NewsModel({
    required super.id,
    required super.slug,
    required super.title,
    super.date,
    super.thumbnailUrl,
    required super.excerpt,
    required super.webUrl,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
    id: json['id'] as String,
    slug: json['slug'] as String,
    title: json['title'] as String,
    date: DateTime.tryParse(json['date'] as String? ?? ''),
    thumbnailUrl: json['thumbnail_url'] as String?,
    excerpt: json['excerpt'] as String? ?? '',
    webUrl: json['web_url'] as String,
  );
}
