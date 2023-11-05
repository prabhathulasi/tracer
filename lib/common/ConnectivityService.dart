import 'dart:async';

//import 'package:connectivity/connectivity.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  StreamController<ConnectivityResult> connectivityController =
      StreamController<ConnectivityResult>();
  Stream<ConnectivityResult> get connectivityStream =>
      connectivityController.stream;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((event) {
      connectivityController.add(event);
    });
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}
