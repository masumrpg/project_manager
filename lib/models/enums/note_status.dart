import 'package:hive/hive.dart';

part 'note_status.g.dart';

@HiveType(typeId: 5)
enum NoteStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  active,
  @HiveField(2)
  archived,
  @HiveField(3)
  deleted,
}

extension NoteStatusX on NoteStatus {
  String get label {
    switch (this) {
      case NoteStatus.draft:
        return 'Draft';
      case NoteStatus.active:
        return 'Active';
      case NoteStatus.archived:
        return 'Archived';
      case NoteStatus.deleted:
        return 'Deleted';
    }
  }
}