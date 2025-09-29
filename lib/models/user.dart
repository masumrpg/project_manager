
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 7)
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String role;

  User({required this.name, required this.role});
}
