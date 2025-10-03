import 'package:flutter/material.dart';

enum TodoStatus { pending, inProgress, completed, cancelled }

extension TodoStatusX on TodoStatus {
  Color get color {
    switch (this) {
      case TodoStatus.pending:
        return Colors.grey.shade600;
      case TodoStatus.inProgress:
        return Colors.blue.shade600;
      case TodoStatus.completed:
        return Colors.green.shade600;
      case TodoStatus.cancelled:
        return Colors.red.shade600;
    }
  }

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
    }
  }

  String get apiValue {
    switch (this) {
      case TodoStatus.pending:
        return 'pending';
      case TodoStatus.inProgress:
        return 'in_progress';
      case TodoStatus.completed:
        return 'completed';
      case TodoStatus.cancelled:
        return 'cancelled';
    }
  }

  static TodoStatus fromApiValue(String value) {
    switch (value) {
      case 'in_progress':
        return TodoStatus.inProgress;
      case 'completed':
        return TodoStatus.completed;
      case 'cancelled':
        return TodoStatus.cancelled;
      case 'pending':
      default:
        return TodoStatus.pending;
    }
  }
}
