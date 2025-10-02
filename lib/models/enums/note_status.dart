enum NoteStatus { draft, active, archived }

extension NoteStatusX on NoteStatus {
  String get label {
    switch (this) {
      case NoteStatus.draft:
        return 'Draft';
      case NoteStatus.active:
        return 'Active';
      case NoteStatus.archived:
        return 'Archived';
    }
  }

  String get apiValue {
    switch (this) {
      case NoteStatus.draft:
        return 'draft';
      case NoteStatus.active:
        return 'active';
      case NoteStatus.archived:
        return 'archived';
    }
  }

  static NoteStatus fromApiValue(String value) {
    switch (value) {
      case 'active':
        return NoteStatus.active;
      case 'archived':
        return NoteStatus.archived;
      case 'draft':
      default:
        return NoteStatus.draft;
    }
  }
}
