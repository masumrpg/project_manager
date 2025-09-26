// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvironmentAdapter extends TypeAdapter<Environment> {
  @override
  final int typeId = 1;

  @override
  Environment read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Environment.development;
      case 1:
        return Environment.staging;
      case 2:
        return Environment.production;
      case 3:
        return Environment.testing;
      case 4:
        return Environment.local;
      default:
        return Environment.development;
    }
  }

  @override
  void write(BinaryWriter writer, Environment obj) {
    switch (obj) {
      case Environment.development:
        writer.writeByte(0);
        break;
      case Environment.staging:
        writer.writeByte(1);
        break;
      case Environment.production:
        writer.writeByte(2);
        break;
      case Environment.testing:
        writer.writeByte(3);
        break;
      case Environment.local:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
