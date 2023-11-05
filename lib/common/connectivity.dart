import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityCheck {
  Future<bool> isInternetAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connectivity
      return false;
    } else {
      // Internet connectivity is available
      return true;
    }
  }
}
