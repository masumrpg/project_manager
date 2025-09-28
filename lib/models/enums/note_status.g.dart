// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteStatusAdapter extends TypeAdapter<NoteStatus> {
  @override
  final int typeId = 5;

  @override
  NoteStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NoteStatus.draft;
      case 1:
        return NoteStatus.active;
      case 2:
        return NoteStatus.archived;
      case 3:
        return NoteStatus.deleted;
      default:
        return NoteStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, NoteStatus obj) {
    switch (obj) {
      case NoteStatus.draft:
        writer.writeByte(0);
        break;
      case NoteStatus.active:
        writer.writeByte(1);
        break;
      case NoteStatus.archived:
        writer.writeByte(2);
        break;
      case NoteStatus.deleted:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
