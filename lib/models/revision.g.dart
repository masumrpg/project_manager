// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revision.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RevisionAdapter extends TypeAdapter<Revision> {
  @override
  final int typeId = 12;

  @override
  Revision read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Revision(
      id: fields[0] as String,
      version: fields[1] as String,
      description: fields[2] as String,
      changes: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Revision obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.changes)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevisionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
