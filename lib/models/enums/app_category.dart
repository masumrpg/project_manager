import 'package:hive/hive.dart';

part 'app_category.g.dart';

@HiveType(typeId: 0)
enum AppCategory {
  @HiveField(0)
  personal,
  @HiveField(1)
  work,
  @HiveField(2)
  study,
  @HiveField(3)
  health,
  @HiveField(4)
  finance,
  @HiveField(5)
  travel,
  @HiveField(6)
  shopping,
  @HiveField(7)
  entertainment,
  @HiveField(8)
  family,
  @HiveField(9)
  other,
}

extension AppCategoryX on AppCategory {
  String get label {
    switch (this) {
      case AppCategory.personal:
        return 'Personal';
      case AppCategory.work:
        return 'Work';
      case AppCategory.study:
        return 'Study';
      case AppCategory.health:
        return 'Health';
      case AppCategory.finance:
        return 'Finance';
      case AppCategory.travel:
        return 'Travel';
      case AppCategory.shopping:
        return 'Shopping';
      case AppCategory.entertainment:
        return 'Entertainment';
      case AppCategory.family:
        return 'Family';
      case AppCategory.other:
        return 'Other';
    }
  }
}
