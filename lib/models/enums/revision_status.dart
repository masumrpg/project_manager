import 'package:hive/hive.dart';

part 'revision_status.g.dart';

@HiveType(typeId: 6)
enum RevisionStatus {
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

extension RevisionStatusX on RevisionStatus {
  String get label {
    switch (this) {
      case RevisionStatus.pending:
        return 'Pending';
      case RevisionStatus.inProgress:
        return 'In Progress';
      case RevisionStatus.completed:
        return 'Completed';
      case RevisionStatus.cancelled:
        return 'Cancelled';
      case RevisionStatus.onHold:
        return 'On Hold';
    }
  }
}