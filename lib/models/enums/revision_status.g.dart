// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revision_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RevisionStatusAdapter extends TypeAdapter<RevisionStatus> {
  @override
  final int typeId = 6;

  @override
  RevisionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RevisionStatus.draft;
      case 1:
        return RevisionStatus.published;
      case 2:
        return RevisionStatus.deprecated;
      case 3:
        return RevisionStatus.archived;
      default:
        return RevisionStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, RevisionStatus obj) {
    switch (obj) {
      case RevisionStatus.draft:
        writer.writeByte(0);
        break;
      case RevisionStatus.published:
        writer.writeByte(1);
        break;
      case RevisionStatus.deprecated:
        writer.writeByte(2);
        break;
      case RevisionStatus.archived:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevisionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
