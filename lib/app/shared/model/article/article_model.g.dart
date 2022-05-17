// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 0;

  @override
  Article read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Article(
      fields[0] as int,
      fields[1] as String,
      (fields[2] as List).cast<Author>(),
      fields[3] as String?,
      fields[4] as String?,
      fields[5] as String?,
      fields[6] as String?,
    )..downloadFile = fields[7] as String?;
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.authors)
      ..writeByte(3)
      ..write(obj.publisher)
      ..writeByte(4)
      ..write(obj.publishedDate)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.downloadUrl)
      ..writeByte(7)
      ..write(obj.downloadFile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
      json['id'] as int,
      json['title'] as String,
      (json['authors'] as List<dynamic>)
          .map((e) => Author.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['publisher'] as String?,
      json['publishedDate'] as String?,
      json['abstract'] as String?,
      json['downloadUrl'] as String?,
    )..downloadFile = json['downloadFile'] as String?;

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'authors': instance.authors,
      'publisher': instance.publisher,
      'publishedDate': instance.publishedDate,
      'abstract': instance.summary,
      'downloadUrl': instance.downloadUrl,
      'downloadFile': instance.downloadFile,
    };
