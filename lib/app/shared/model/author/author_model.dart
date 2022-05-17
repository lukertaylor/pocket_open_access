import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'author_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Author extends Equatable {
  @HiveField(0)
  final String name;

  const Author(this.name);

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorToJson(this);

  @override
  List<Object?> get props => [name];
}
