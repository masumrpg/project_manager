enum TodoStatus { pending, inProgress, completed, cancelled }

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
