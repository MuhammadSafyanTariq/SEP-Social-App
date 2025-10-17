import 'dart:convert';
import 'package:http/http.dart';
import 'package:sep/services/networking/urls.dart';

import '../../feature/data/models/dataModels/responseDataModel.dart';
import '../../utils/appUtils.dart';
import 'package:http_parser/http_parser.dart';

class ApiUtils {
  // static Future<Response> getMethod(
  //         {required Uri url, Map<String, String>? headers}) =>
  //     get(url, headers: headers,);


  static Future<Response> getMethod(
      {required Uri url, Map<String, String>? headers,
        Map<String, dynamic>? body,
      }) async{
    var request = MultipartRequest('GET', url);
    if(headers != null){
      request.headers.addAll(headers);
    }
    if (body != null) {
      // Convert the body map to JSON
      var jsonBody = jsonEncode(body);

      // Set the JSON body to the request
      request.fields['_json'] = jsonBody; // You can use a custom field key if required


      // for (var entry in body.entries) {
      //   request.fields[entry.key] = entry.value.toString();
      // }
    }

    var streamedResponse = await request.send();
    var response = await Response.fromStream(streamedResponse);
    return response;
  }

  static Future<Response> postMethod(
      {required Uri url,
      Map<String, String>? headers,
      Map<String, dynamic>? body,
      Map<String, dynamic>? multipartFile,
        bool isMultipartFromPath = true

      }) async {
    // print(url.path);
    // AppUtils.log(Urls.appApiBaseUrl+url.path);
    AppUtils.log(Urls.appApiBaseUrl+url.path);
    AppUtils.log(headers);
    AppUtils.log(body);

    // AppUtils.log(multipartFile);
    // AppUtils.log(body);
    if (multipartFile != null) {
      var request = MultipartRequest('POST', url);
      if(headers != null){
        request.headers.addAll(headers);
      }
      for (var entry in multipartFile.entries) {
        String fieldName = entry.key;
        dynamic filePath = entry.value;
        request.files.add(
            isMultipartFromPath ?
          await MultipartFile.fromPath(fieldName, filePath) : MultipartFile.fromBytes(
              fieldName, filePath,
              filename: "thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg",
              contentType: MediaType("image", "jpeg"),
            ),
        );
      }
      if (body != null) {
        for (var entry in body.entries) {
          request.fields[entry.key] = entry.value.toString();
        }
      }
      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);
      return response;
    } else {
      return post(url, headers: headers, body: jsonEncode(body));
    }
  }

  static Future<Response> putMethod(
      {required Uri url,
      Map<String, String>? headers,
      Map<String, dynamic>? body,
        Map<String, String>? multipartFile
      }) async{
    if (multipartFile != null) {
      var request = MultipartRequest('PUT', url);
      if(headers != null){
        AppUtils.log(headers);
        request.headers.addAll(headers);
      }

      for (var entry in multipartFile.entries) {
        String fieldName = entry.key;
        String filePath = entry.value;
        request.files.add(
          await MultipartFile.fromPath(fieldName, filePath),
        );
      }
      if (body != null) {
        for (var entry in body.entries) {
          request.fields[entry.key] = entry.value.toString();
        }
      }
      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);
      return response;
    }


    // print(url.path);
    // print(headers);
    // print(body);
    return put(url, headers: headers, body: jsonEncode(body));
  }

  static Future<Response> deleteMethod({
    required Uri url,
    Map<String, String>? headers,
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    Uri uri = generateUri(url.toString(), query);

    final request = Request('DELETE', uri);
    if (headers != null) request.headers.addAll(headers);

    if (body != null) {
      request.body = jsonEncode(body);
      request.headers['Content-Type'] = 'application/json';
    }

    final streamedResponse = await request.send();
    return Response.fromStream(streamedResponse);
  }





  static Future<ResponseData<Map<String, dynamic>>> call({
    Map<String,dynamic>? responseStatusValue,
    bool? withoutStatus = false,
    required Map<String, dynamic>? requestData,
    required Future<Response> request,
    required Map<String, dynamic> Function(Map<String, dynamic>) data,
    Function(ResponseData)? error,

  }) async {
    // try{
    final result = await request;


    AppUtils.log({
      'method':result.request?.method,
      'url':{
        'authority':result.request?.url.authority,
        'fragment':result.request?.url.fragment,
        'host':result.request?.url.host,
        'origin':result.request?.url.origin,
        'path':result.request?.url.path,
        'pathSegments':result.request?.url.pathSegments.join('::'),
        'queryParameters':result.request?.url.queryParameters,
        'scheme':result.request?.url.scheme,
        'userInfo':result.request?.url.userInfo,
      },
      'requestBody': requestData,
      'headers': result.request?.headers,
      'statusCode': result.statusCode,
      'resultData':result.body
    });
    // AppUtils.log(result.statusCode);
    // AppUtils.log(result.body);
    // AppUtils.log(result.body);

    // AppUtils.log('statuscodse ::: ${result.statusCode}');
    if (result.statusCode >= 200 && result.statusCode < 300) {
      final body = jsonDecode(result.body) as Map<String, dynamic>;

      AppUtils.log(body);
      if ((withoutStatus ?? false)
          ? true
          : (responseStatusValue != null
          ? body[responseStatusValue['key']] == responseStatusValue['value']
          : (body['status'] == true || body['success'] == true))) {

        return generateResponse<Map<String, dynamic>>(data(body), result.statusCode);
      }
      else {
        return ResponseData(
          statusCode: result.statusCode,
            data: body, isSuccess: false, error: Exception(body['message']));
        // return error?.call(ResponseData(
        //     data: body, isSuccess: false, error: Exception(body['message'])));
      }
    } else {




      String errorMsg = _statusErrors(result.statusCode);

      AppUtils.log(errorMsg);

      try{
       final error =  jsonDecode(result.body) as Map<String,dynamic>;
       if(error.containsKey('error')){
         errorMsg = error['error'];
       }else if(error.containsKey('message')){
         errorMsg = error['message'];
       }
      }catch(e){

      }
      // AppUtils.log(result.body);





      return ResponseData(
        statusCode: result.statusCode,
          isSuccess: false, error: Exception(errorMsg));
    }
    // }catch(e){
    //   return error?.call(ResponseData(
    //       isSuccess: false,
    //       error: Exception(e.toString())
    //   ));
    // }
  }





  static ResponseData<T> generateResponse<T>(T data, int statusCode) =>
      ResponseData(isSuccess: true, data: data, statusCode: statusCode);

  static Uri generateUri(String url, Map<String, String>? query) {
    // AppUtils.log(url);
    Uri uri = Uri.parse(url);
    if (query != null) {
      final obj = uri.replace(queryParameters: query);
      uri = obj;
    }
    return uri;
  }

  static Map<String,String> headerGen({String? authToken, bool isMultipart = false}){
    Map<String,String> token = authToken != null ? {'Authorization':authToken} : <String,String>{};
    return {
      "Content-Type": isMultipart ? 'multipart/form-data' : "application/json",
      ...token
    };
  }


  static String _statusErrors(int statusCode) {
    String error = '';
    switch (statusCode) {
      case 400:
        error = 'Bad Request Exception';
        break;
      case 401:
        error = 'Unauthorised Exception';
        break;
      case 403:
        error = 'Access to the requested resource is forbidden';
        break;
      case 500:
        error = 'Internal Server Error';
        break;
      default:
        error = 'Unknown error: $statusCode';
        break;
    }
    return error;
  }
}
