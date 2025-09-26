import 'package:hive/hive.dart';

part 'environment.g.dart';

@HiveType(typeId: 1)
enum Environment {
  @HiveField(0)
  development,
  @HiveField(1)
  staging,
  @HiveField(2)
  production,
  @HiveField(3)
  testing,
  @HiveField(4)
  local,
}

extension EnvironmentX on Environment {
  String get label {
    switch (this) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
      case Environment.testing:
        return 'Testing';
      case Environment.local:
        return 'Local';
    }
  }
}
