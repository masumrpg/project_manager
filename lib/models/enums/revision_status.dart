import 'package:hive/hive.dart';

part 'revision_status.g.dart';

@HiveType(typeId: 6)
enum RevisionStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  published,
  @HiveField(2)
  deprecated,
  @HiveField(3)
  archived,
}

extension RevisionStatusX on RevisionStatus {
  String get label {
    switch (this) {
      case RevisionStatus.draft:
        return 'Draft';
      case RevisionStatus.published:
        return 'Published';
      case RevisionStatus.deprecated:
        return 'Deprecated';
      case RevisionStatus.archived:
        return 'Archived';
    }
  }
}