import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

part 'article_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Article extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<Author> authors;

  @HiveField(3)
  final String? publisher;

  @HiveField(4)
  String? publishedDate;

  @JsonKey(name: 'abstract')
  @HiveField(5)
  final String? summary;

  @HiveField(6)
  final String? downloadUrl;

  @HiveField(7)
  String? downloadFile;

  Article(
    this.id,
    this.title,
    this.authors,
    this.publisher,
    this.publishedDate,
    this.summary,
    this.downloadUrl,
  );

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}
