import 'package:hive/hive.dart';

import 'enums/revision_status.dart';

part 'revision.g.dart';

@HiveType(typeId: 12)
class Revision extends HiveObject {
  Revision({
    required this.id,
    required this.version,
    required this.description,
    required this.changes,
    this.status = RevisionStatus.pending,
    required this.createdAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String version;

  @HiveField(2)
  String description;

  @HiveField(3)
  String changes;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  RevisionStatus status;
}
