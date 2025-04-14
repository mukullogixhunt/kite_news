import 'package:equatable/equatable.dart';


class SourceEntity extends Equatable {
  final String? id; 
  final String name;

  const SourceEntity({this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}


class ArticleEntity extends Equatable {
  final SourceEntity source;
  final String? author; 
  final String title;
  final String? description; 
  final String url; 
  final String? urlToImage; 
  final DateTime? publishedAt; 
  final String? content; 

  const ArticleEntity({
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  @override
  List<Object?> get props => [
    source,
    author,
    title,
    description,
    url,
    urlToImage,
    publishedAt,
    content,
  ];
}