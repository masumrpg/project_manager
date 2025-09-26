// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppCategoryAdapter extends TypeAdapter<AppCategory> {
  @override
  final int typeId = 0;

  @override
  AppCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppCategory.personal;
      case 1:
        return AppCategory.work;
      case 2:
        return AppCategory.study;
      case 3:
        return AppCategory.health;
      case 4:
        return AppCategory.finance;
      case 5:
        return AppCategory.travel;
      case 6:
        return AppCategory.shopping;
      case 7:
        return AppCategory.entertainment;
      case 8:
        return AppCategory.family;
      case 9:
        return AppCategory.other;
      default:
        return AppCategory.personal;
    }
  }

  @override
  void write(BinaryWriter writer, AppCategory obj) {
    switch (obj) {
      case AppCategory.personal:
        writer.writeByte(0);
        break;
      case AppCategory.work:
        writer.writeByte(1);
        break;
      case AppCategory.study:
        writer.writeByte(2);
        break;
      case AppCategory.health:
        writer.writeByte(3);
        break;
      case AppCategory.finance:
        writer.writeByte(4);
        break;
      case AppCategory.travel:
        writer.writeByte(5);
        break;
      case AppCategory.shopping:
        writer.writeByte(6);
        break;
      case AppCategory.entertainment:
        writer.writeByte(7);
        break;
      case AppCategory.family:
        writer.writeByte(8);
        break;
      case AppCategory.other:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
