import 'package:flutter/material.dart';

enum NoteStatus { draft, active, archived }

extension NoteStatusX on NoteStatus {
  Color get color {
    switch (this) {
      case NoteStatus.draft:
        return Colors.grey.shade600;
      case NoteStatus.active:
        return Colors.green.shade600;
      case NoteStatus.archived:
        return Colors.red.shade600;
    }
  }

  String get label {
    switch (this) {
      case NoteStatus.draft:
        return 'Draf';
      case NoteStatus.active:
        return 'Aktif';
      case NoteStatus.archived:
        return 'Diarsipkan';
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
