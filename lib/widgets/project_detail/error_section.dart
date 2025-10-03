import 'package:flutter/material.dart';

import 'empty_state.dart';

class ErrorSection extends StatelessWidget {
  const ErrorSection({required this.message, required this.onRetry, super.key});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      description: message,
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

