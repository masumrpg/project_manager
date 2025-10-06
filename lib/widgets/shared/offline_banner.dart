import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStreamProvider);

    // Show banner if there is a value and it's none
    final isOffline = connectivity.hasValue && connectivity.value == ConnectivityResult.none;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOffline ? 30 : 0,
      color: Colors.red.shade700,
      child: isOffline
          ? const Center(
              child: Text(
                'You are currently offline',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
    );
  }
}
