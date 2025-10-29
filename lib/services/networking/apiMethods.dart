import 'package:sep/services/networking/urls.dart';

import '../../feature/data/models/dataModels/responseDataModel.dart';
import 'apiUtils.dart';

abstract class ApiMethods {
  Future<ResponseData<Map<String, dynamic>>> get({
    required String url,
    String? authToken,
    Map<String, String>? query,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? responseStatusValue,
  });

  Future<ResponseData<Map<String, dynamic>>> post({
    required String url,
    String? authToken,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, String>? multipartFile,
    Map<String, dynamic>? responseStatusValue,
    required Map<String, String> headers,
    bool? withoutStatus,
    bool? isMultipartFromPath
  });

  Future<ResponseData<Map<String, dynamic>>> put({
    required String url,
    String? authToken,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, String>? multipartFile,
    Map<String, dynamic>? responseStatusValue,
    required Map<String, String> headers,
  });

  Future<ResponseData<Map<String, dynamic>>> delete({
    required String url,
    String? authToken,
    Map<String, String>? query,
    Map<String, dynamic>? responseStatusValue,
  });

}

class IApiMethod implements ApiMethods {
  String? baseUrl;

  IApiMethod({String? baseUrl}) {
    this.baseUrl = baseUrl ?? Urls.appApiBaseUrl;
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> get({
    required String url,
    String? authToken,
    Map<String, String>? query,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? responseStatusValue,
  }) async {

    final effectiveHeaders = {
      ...ApiUtils.headerGen(
        authToken: authToken
      ),
      ...(headers?? {}),
    };
    final bUrl = baseUrl;
    final uri = ApiUtils.generateUri('$bUrl$url', query);
    return ApiUtils.call(
      requestData: body,
      request: ApiUtils.getMethod(
        url: uri,
        // headers: ApiUtils.headerGen(authToken: authToken),
        headers: effectiveHeaders,
        body: body
      ),
      data: (data) => data,
      error: (error) => error,
      responseStatusValue: responseStatusValue,
    );
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> post({
    required String url,
    String? authToken,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, dynamic>? multipartFile,
    Map<String, dynamic>? responseStatusValue,
    bool? withoutStatus,
    required Map<String, String> headers,
    bool? isMultipartFromPath
  }) {
    final bUrl = baseUrl;
    final uri = ApiUtils.generateUri('$bUrl$url', query);

    final effectiveHeaders = {
      ...ApiUtils.headerGen(
        authToken: authToken,
        isMultipart: multipartFile != null,
      ),
      ...headers,
    };

    return ApiUtils.call(
      requestData: body,
      withoutStatus: withoutStatus,
      request: ApiUtils.postMethod(
        url: uri,
        body: body,
        multipartFile: multipartFile,
        headers: effectiveHeaders,
          isMultipartFromPath: isMultipartFromPath ?? true
      ),

      data: (data) => data,
      error: (error) => error,
      responseStatusValue: responseStatusValue,
    );
  }


  @override
  Future<ResponseData<Map<String, dynamic>>> put({
    required String url,
    String? authToken,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, String>? multipartFile,
    Map<String, dynamic>? responseStatusValue,
    required Map<String, String> headers,
  }) {
    final effectiveHeaders = {
      ...ApiUtils.headerGen(
        authToken: authToken,
        isMultipart: multipartFile != null,
      ),
      ...headers,
    };
    final bUrl = baseUrl;
    final uri = ApiUtils.generateUri('$bUrl$url', query);
    return ApiUtils.call(
      requestData: body,
      request: ApiUtils.putMethod(
        url: uri,
        body: body,
        multipartFile: multipartFile,
        headers: effectiveHeaders,
      ),

      data: (data) => data,
      error: (error) => error,
      responseStatusValue: responseStatusValue,
    );
  }


  @override
  Future<ResponseData<Map<String, dynamic>>> delete({
    required String url,
    String? authToken,
    Map<String, String>? query,
    Map<String, dynamic>? body,
    Map<String, dynamic>? responseStatusValue,
  }) {
    final bUrl = baseUrl;
    final uri = ApiUtils.generateUri('$bUrl$url', query);
    return ApiUtils.call(
      requestData: body,
      request: ApiUtils.deleteMethod(
        url: uri,
        headers: ApiUtils.headerGen(authToken: authToken),
        query: query,
        body: body,
      ),
      data: (data) => data,
      error: (error) => error,
      responseStatusValue: responseStatusValue,
    );
  }

}

