import 'package:flutter/material.dart';
import 'home_constants.dart';

// Centered Loader
class CenteredLoader extends StatelessWidget {
  const CenteredLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: HomeConstants.accentOrange,
      ),
    );
  }
}

// Empty State
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HomeConstants.accentOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 64,
              color: HomeConstants.accentOrange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Projects Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: HomeConstants.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: HomeConstants.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Error State
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: HomeConstants.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: HomeConstants.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: HomeConstants.accentOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}