import 'package:flutter/material.dart';

enum RevisionStatus { pending, approved, rejected }

extension RevisionStatusX on RevisionStatus {
  Color get color {
    switch (this) {
      case RevisionStatus.pending:
        return Colors.blue.shade600;
      case RevisionStatus.approved:
        return Colors.green.shade600;
      case RevisionStatus.rejected:
        return Colors.red.shade600;
    }
  }

  String get label {
    switch (this) {
      case RevisionStatus.pending:
        return 'Pending';
      case RevisionStatus.approved:
        return 'Approved';
      case RevisionStatus.rejected:
        return 'Rejected';
    }
  }

  String get apiValue {
    switch (this) {
      case RevisionStatus.pending:
        return 'pending';
      case RevisionStatus.approved:
        return 'approved';
      case RevisionStatus.rejected:
        return 'rejected';
    }
  }

  static RevisionStatus fromApiValue(String value) {
    switch (value) {
      case 'approved':
        return RevisionStatus.approved;
      case 'rejected':
        return RevisionStatus.rejected;
      case 'pending':
      default:
        return RevisionStatus.pending;
    }
  }
}
