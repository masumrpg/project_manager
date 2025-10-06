import 'package:catatan_kaki/services/background_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoSyncAsync = ref.watch(autoSyncEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          autoSyncAsync.when(
            data: (isEnabled) => ListTile(
              title: const Text('Auto Sync'),
              subtitle: const Text('Sync periodically in the background'),
              trailing: Switch(
                value: isEnabled,
                onChanged: (value) async {
                  await ref.read(settingsServiceProvider).setAutoSyncEnabled(value);
                  if (value) {
                    Workmanager().registerPeriodicTask(
                      "1",
                      backgroundSyncTask,
                      frequency: const Duration(minutes: 15),
                      constraints: Constraints(
                        networkType: NetworkType.connected,
                      ),
                    );
                  } else {
                    Workmanager().cancelByUniqueName("1");
                  }
                  ref.refresh(autoSyncEnabledProvider);
                },
              ),
            ),
            loading: () => const ListTile(title: Text('Loading...')),
            error: (e, s) => const ListTile(title: Text('Error loading setting')),
          ),
          ListTile(
            title: const Text('Force Sync'),
            subtitle: const Text('Manually sync all data with the server'),
            onTap: () {
              ref.read(syncServiceProvider).syncProjects();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync started...')),
              );
            },
          ),
          ListTile(
            title: const Text('Clear Local Cache'),
            subtitle: const Text('Delete all locally stored data'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Cache?'),
                  content: const Text(
                      'This will delete all local data. Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(appDatabaseProvider).deleteAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Local cache cleared.')),
                );
              }
            },
          ),
          const ListTile(
            title: Text('Storage Usage'),
            subtitle: Text('Not implemented'),
          ),
        ],
      ),
    );
  }
}
