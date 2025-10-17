import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  RxBool isConnected = true.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkInternetConnection();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      updateConnectionStatusFromList(results);
    });
  }

  Future<void> checkInternetConnection() async {
    isLoading.value = true;
    var connectivityResult = await Connectivity().checkConnectivity();
    updateConnectionStatus(connectivityResult);
    isLoading.value = false;
  }

  void updateConnectionStatus(List<ConnectivityResult> result) {
    isConnected.value = !result.contains(ConnectivityResult.none);
  }

  void updateConnectionStatusFromList(List<ConnectivityResult> results) {
    isConnected.value = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
  }

  Future<bool> refreshConnection() async {
    await checkInternetConnection();
    return isConnected.value;
  }

}
