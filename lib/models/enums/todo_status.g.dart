// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoStatusAdapter extends TypeAdapter<TodoStatus> {
  @override
  final int typeId = 4;

  @override
  TodoStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TodoStatus.pending;
      case 1:
        return TodoStatus.inProgress;
      case 2:
        return TodoStatus.completed;
      case 3:
        return TodoStatus.cancelled;
      case 4:
        return TodoStatus.onHold;
      default:
        return TodoStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TodoStatus obj) {
    switch (obj) {
      case TodoStatus.pending:
        writer.writeByte(0);
        break;
      case TodoStatus.inProgress:
        writer.writeByte(1);
        break;
      case TodoStatus.completed:
        writer.writeByte(2);
        break;
      case TodoStatus.cancelled:
        writer.writeByte(3);
        break;
      case TodoStatus.onHold:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
