import 'package:stack_wealth_news/features/news/domain/entities/article_entity.dart';


class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required SourceModel super.source, 
    super.author,
    required super.title,
    super.description,
    required super.url,
    super.urlToImage,
    required super.publishedAt, 
    super.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    
    DateTime? parseDateTime(String? dateString) {
      if (dateString == null || dateString.isEmpty) {
        return null;
      }
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        print("Error parsing date: $dateString - $e"); 
        return null; 
      }
    }

    return ArticleModel(
      
      source: json['source'] is Map<String, dynamic>
          ? SourceModel.fromJson(json['source'] as Map<String, dynamic>)
          : const SourceModel(id: null, name: 'Unknown Source'), 
      author: json['author'] as String?,
      title: json['title'] as String? ?? 'No Title Provided', 
      description: json['description'] as String?,
      url: json['url'] as String? ?? '', 
      urlToImage: json['urlToImage'] as String?,
      publishedAt: parseDateTime(json['publishedAt'] as String?),
      content: json['content'] as String?,
    );
  }


}


class SourceModel extends SourceEntity {
  const SourceModel({super.id, required super.name});

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      id: json['id'] as String?, 
      name: json['name'] as String? ?? 'Unknown Source', 
    );
  }
}