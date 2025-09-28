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
        return RevisionStatus.pending;
      case 1:
        return RevisionStatus.inProgress;
      case 2:
        return RevisionStatus.completed;
      case 3:
        return RevisionStatus.cancelled;
      case 4:
        return RevisionStatus.onHold;
      default:
        return RevisionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, RevisionStatus obj) {
    switch (obj) {
      case RevisionStatus.pending:
        writer.writeByte(0);
        break;
      case RevisionStatus.inProgress:
        writer.writeByte(1);
        break;
      case RevisionStatus.completed:
        writer.writeByte(2);
        break;
      case RevisionStatus.cancelled:
        writer.writeByte(3);
        break;
      case RevisionStatus.onHold:
        writer.writeByte(4);
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
