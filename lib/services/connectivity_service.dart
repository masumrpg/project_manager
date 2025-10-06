import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Stream<ConnectivityResult> get onConnectivityChanged =>
      Connectivity().onConnectivityChanged;

  Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
