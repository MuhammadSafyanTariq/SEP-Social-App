// import 'dart:convert';
// import 'dart:io';
//
// import 'package:chopper/chopper.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
//
// import '../../core/core/error.dart';
// import '../../feature/data/models/dataModels/responseDataModel.dart';
// import '../appUtils.dart';
//
// class ApiUtils {
//   static Map<String, dynamic> bodyToMap(Response data) =>
//       data.body is Map<String, dynamic>
//           ? data.body
//           : jsonDecode(data.body) as Map<String, dynamic>;
//
//   static Future<Response> _request(Future<Response<dynamic>> apiRequest) async {
//     await _checkConnectivity();
//     return apiRequest.catchError((onError){
//       throw onError;
//     });
//   }
//
//   static Future<void> _checkConnectivity() async {
//     if (await _NetworkInfo(InternetConnectionChecker()).isConnected) {
//       return;
//     } else {
//       throw const InternetFailure(error: 'Internet not connected');
//     }
//   }
//
//
//   static Future<Response> hitApi(Future<Response<dynamic>> apiRequest) => _hitApi(apiRequest);
//
//   static Future<Response> _hitApi(Future<Response<dynamic>> apiRequest) async {
//     var result = await _request(apiRequest);
//     AppUtils.logEr(result.statusCode);
//     AppUtils.logEr(result.error);
//     AppUtils.log("${result.body}");
//     if (result.isSuccessful) {
//       return result;
//     } else {
//       if (result.body != null) {
//         throw ErrorFailure(error: result.body);
//       } else if (result.error != null) {
//         final Map<String, dynamic> error =
//         jsonDecode(result.error.toString()) as Map<String, dynamic>;
//         throw ErrorFailure(error: error['message']);
//       } else {
//         throw ErrorFailure(error: _throwException(result.statusCode));
//       }
//     }
//   }
//
//   static Future<ResponseData<Map<String, dynamic>>> getJsonResponse(
//       Future<Response> request) async {
//     try {
//       final result = await ApiUtils.hitApi(request);
//       final body = ApiUtils.bodyToMap(result);
//       return wrapResponseData<Map<String, dynamic>>(body);
//     } on Exception catch (e) {
//       return getExceptionData(e);
//     }
//   }
//
//   static String _throwException(int statusCode) {
//     String error = '';
//     switch (statusCode) {
//       case 400:
//         error = 'BadRequest Exception';
//       case 401:
//         error = 'Unauthorised Exception';
//       case 403:
//         error = 'Access to the requested resource is forbidden';
//       case 404:
//         error = 'The requested resource could not be found.';
//       case 408:
//         error = 'The request timed out. Please try again.';
//       case 429:
//         error =
//             'You are making requests too frequently. Please wait a moment and try again.';
//       case 500:
//         error = 'Internal Server Error';
//       case 502:
//         error = 'Bad gateway. Please try again later.';
//       case 503:
//         error = 'Service is temporarily unavailable. Please try again later.';
//       case 504:
//         error =
//             'The server is taking too long to respond. Please try again later.';
//       default:
//         error = '';
//     }
//     return error;
//   }
//
//   static ResponseData<T> getExceptionData<T>(e) {
//     return ResponseData(
//         isSuccess: false,
//         exception: e is Exception ? e : Exception(e),
//         failure: e is Failure ? e : null);
//   }
//
//   static ResponseData<T> wrapResponseData<T>(T data) {
//     return ResponseData(isSuccess: true, data: data);
//   }
//
//   static Map<String, dynamic> _bodyToMap(Response data) =>
//       data.body is Map<String, dynamic>
//           ? data.body
//           : jsonDecode(data.body) as Map<String, dynamic>;
//
//   static ResponseData<T> _wrapResponse<T>({
//     required ResponseData result,
//     required T Function(ResponseData) data,
//     Exception Function(ResponseData)? error,
//     bool Function(ResponseData)? isResultSuccess,
//   }) {
//     // flutter: │ 🐛 {
//     // flutter: │ 🐛   "predictions": [],
//     // flutter: │ 🐛   "status": "ZERO_RESULTS"
//     // flutter: │ 🐛 }
//     // AppUtils.log(result.data);/**/
//     // AppUtils.log(result.errorMessage);
//     if (result.isSuccess) {
//       if (isResultSuccess?.call(result) ?? result.apiStatusSuccess) {
//         return _wrapResponseData<T>(data(result));
//       } else {
//         return _getExceptionData<T>(error != null
//             ? error(result)
//             : ErrorFailure(error: '${result.errorMessage}'));
//       }
//     } else {
//       return _getExceptionData<T>(result.getError);
//     }
//   }
//
//   static Future<ResponseData<T>> request<T>({
//     required Future<Response> request,
//     required T Function(ResponseData) data,
//     bool Function(ResponseData)? isResultSuccess,
//     Exception Function(ResponseData)? error,
//   }) async {
//     try {
//       final response = await _hitApi(request);
//       // AppUtils.log(response);
//       // AppUtils.log(error);
//       final body = _bodyToMap(response);
//       // AppUtils.log(body);
//       // AppUtils.log(error);
//       final result = _wrapResponseData<Map<String, dynamic>>(body);
//
//       return _wrapResponse(
//           result: result,
//           data: data,
//           error: error,
//           isResultSuccess: isResultSuccess);
//     } on Exception catch (e) {
//       AppUtils.log(e);
//       return _getExceptionData<T>(e);
//     }
//   }
//
//   static ResponseData<T> _getExceptionData<T>(e) {
//     return ResponseData(
//         isSuccess: false,
//         exception: e is Exception ? e : Exception(e),
//         failure: e is Failure ? e : null);
//   }
//
//   static ResponseData<T> _wrapResponseData<T>(T data) {
//     return ResponseData(isSuccess: true, data: data);
//   }
// }
//
// abstract class _INetworkInfo {
//   Future<bool> get isConnected;
// }
//
// class _NetworkInfo implements _INetworkInfo {
//   final InternetConnectionChecker connectionChecker;
//
//   _NetworkInfo(this.connectionChecker);
//
//   @override
//   Future<bool> get isConnected async => Platform.isAndroid || Platform.isIOS
//       ? await connectionChecker.hasConnection
//       : true;
// }
