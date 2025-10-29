// import 'dart:convert';
// import 'dart:io';
//
// import 'package:chopper/chopper.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:kioski/core/error.dart';
// import 'package:kioski/utils/appUtils.dart';
//
// import '../feature/data/models/dataModels/responseData.dart';
//
// class ApiUtils {
//   static Map<String, dynamic> bodyToMap(Response data) =>
//       data.body is Map<String, dynamic>
//           ? data.body
//           : jsonDecode(data.body) as Map<String, dynamic>;
//
//   static Future<Response> hitApi(Future<Response<dynamic>> apiRequest) async {
//       await _checkConnectivity();
//       final result = await apiRequest;
//       if (result.isSuccessful) {
//         return result;
//       } else {
//         // AppUtils.logEr(result.statusCode);
//         // AppUtils.logEr(result.error);
//         // AppUtils.logEr(result.body);
//         throw Exception(_throwException(result.statusCode));
//       }
//
//   }
//
//   static String _throwException(int statusCode) {
//     String error = '';
//     switch (statusCode) {
//       case 400:
//         error = 'BadRequestException';
//       case 401:
//         error = 'UnauthorisedException';
//       case 403:
//         error = 'access to the requested resource is forbidden';
//       case 500:
//         error = 'Internal Server Error';
//       default:
//         error = '';
//     }
//     return error;
//   }
//
//   static Future<void> _checkConnectivity() async {
//     if(await _NetworkInfo(InternetConnectionChecker()).isConnected){
//       return ;
//     }else{
//       AppUtils.logEr('Internet not connected');
//       throw const InternetFailure(error: 'Internet not connected');
//     }
// //     final List<ConnectivityResult> connectivityResult =
// //         await (Connectivity().checkConnectivity());
// //
// // // This condition is for demo purposes only to explain every connection type.
// // // Use conditions which work for your requirements.
// //     if (connectivityResult.contains(ConnectivityResult.mobile)) {
// //       // Mobile network available.
// //       return;
// //     } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
// //       return;
// //       // Wi-fi is available.
// //       // Note for Android:
// //       // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
// //     } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
// //       return;
// //       // Ethernet connection available.
// //     } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
// //       return;
// //       // Vpn connection active.
// //       // Note for iOS and macOS:
// //       // There is no separate network interface type for [vpn].
// //       // It returns [other] on any device (also simulator)
// //     } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
// //       return;
// //       // Bluetooth connection available.
// //     } else if (connectivityResult.contains(ConnectivityResult.other)) {
// //       return;
// //       // Connected to a network which is not in the above mentioned networks.
// //     } else if (connectivityResult.contains(ConnectivityResult.none)) {
// //       // No available network types
// //       throw const InternetFailure(error: 'Internet not connected');
// //     }
//   }
//
//
//   static ResponseData<T> getExceptionData<T>(e){
//     return ResponseData(isSuccess: false,
//         exception: e is Exception ? e : Exception(e),
//       failure: e is Failure ? e : null
//     );
//   }
//
//   static ResponseData<T> wrapResponseData<T>(T data){
//     return ResponseData(isSuccess: true, data: data);
//   }
// }
//
//
// abstract class _INetworkInfo {
//   Future<bool> get isConnected;
// }
//
// class _NetworkInfo implements _INetworkInfo {
//   final InternetConnectionChecker connectionChecker;
//   _NetworkInfo(this.connectionChecker);
//   @override
//   Future<bool> get isConnected async => Platform.isAndroid || Platform.isIOS
//       ? await connectionChecker.hasConnection
//       : true;
// }
//
//
