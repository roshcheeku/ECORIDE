import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  // Method to check network status and return a boolean value
  Future<bool> checkNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Method to print network status
  Future<void> printNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection');
    } else {
      print('Connected to the internet');
    }
  }
}
