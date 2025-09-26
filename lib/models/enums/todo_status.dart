import 'package:hive/hive.dart';

part 'todo_status.g.dart';

@HiveType(typeId: 4)
enum TodoStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled,
  @HiveField(4)
  onHold,
}

extension TodoStatusX on TodoStatus {
  String get label {
    switch (this) {
      case TodoStatus.pending:
        return 'Pending';
      case TodoStatus.inProgress:
        return 'In Progress';
      case TodoStatus.completed:
        return 'Completed';
      case TodoStatus.cancelled:
        return 'Cancelled';
      case TodoStatus.onHold:
        return 'On Hold';
    }
  }
}
