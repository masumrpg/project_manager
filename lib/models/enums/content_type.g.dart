// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentTypeAdapter extends TypeAdapter<ContentType> {
  @override
  final int typeId = 2;

  @override
  ContentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ContentType.text;
      case 1:
        return ContentType.markdown;
      case 2:
        return ContentType.code;
      case 3:
        return ContentType.image;
      case 4:
        return ContentType.link;
      case 5:
        return ContentType.document;
      default:
        return ContentType.text;
    }
  }

  @override
  void write(BinaryWriter writer, ContentType obj) {
    switch (obj) {
      case ContentType.text:
        writer.writeByte(0);
        break;
      case ContentType.markdown:
        writer.writeByte(1);
        break;
      case ContentType.code:
        writer.writeByte(2);
        break;
      case ContentType.image:
        writer.writeByte(3);
        break;
      case ContentType.link:
        writer.writeByte(4);
        break;
      case ContentType.document:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
