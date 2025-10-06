import 'package:catatan_kaki/main.dart';
import 'package:catatan_kaki/providers.dart';
import 'package:workmanager/workmanager.dart';

const backgroundSyncTask = "com.catatankaki.projectmanager.backgroundSync";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == backgroundSyncTask) {
      print("Starting background sync...");
      try {
        // We need to re-create the dependency injection container for the background isolate.
        final container = await createContainer();
        await container.read(syncServiceProvider).syncProjects();
        print("Background sync completed.");
        return Future.value(true);
      } catch (e) {
        print("Background sync failed: $e");
        return Future.value(false);
      }
    }
    return Future.value(false);
  });
}
