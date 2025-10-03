import 'package:flutter/material.dart';

enum TodoPriority { low, medium, high, urgent }

extension TodoPriorityX on TodoPriority {
  Color get color {
    switch (this) {
      case TodoPriority.low:
        return Colors.green.shade600;
      case TodoPriority.medium:
        return Colors.orange.shade600;
      case TodoPriority.high:
        return Colors.red.shade600;
      case TodoPriority.urgent:
        return Colors.purple.shade600;
    }
  }

  String get label {
    switch (this) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.high:
        return 'High';
      case TodoPriority.urgent:
        return 'Urgent';
    }
  }

  String get apiValue {
    switch (this) {
      case TodoPriority.low:
        return 'low';
      case TodoPriority.medium:
        return 'medium';
      case TodoPriority.high:
        return 'high';
      case TodoPriority.urgent:
        return 'urgent';
    }
  }

  static TodoPriority fromApiValue(String value) {
    switch (value) {
      case 'medium':
        return TodoPriority.medium;
      case 'high':
        return TodoPriority.high;
      case 'urgent':
        return TodoPriority.urgent;
      case 'low':
      default:
        return TodoPriority.low;
    }
  }
}
