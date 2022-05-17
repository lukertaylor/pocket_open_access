import 'package:json_annotation/json_annotation.dart';

import '../../common_imports/common_imports_barrel.dart';

part 'response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Response {
  @JsonKey(name: 'results')
  final List<Article> articles;

  const Response(this.articles);

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
