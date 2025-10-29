import '../../../../core/core/error.dart';

class ResponseData<T> {
  bool isSuccess;
  int? statusCode;
  T? data;
  Exception? error;
  Exception? exception;
  Failure? failure;

  ResponseData({
    this.isSuccess = false,
    this.data,
    this.error,
    this.exception,
    this.failure,
     this.statusCode
  });


  Exception? get getError => this.failure ?? this.exception ?? this.error;



  factory ResponseData.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ResponseData<T>(
      isSuccess: json['isSuccess'] ?? false,
      statusCode: json['statusCode'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'] is String ? Exception(json['error']) : null,
      exception: json['exception'] is String ? Exception(json['exception']) : null,
      failure: json['failure'] != null ? Failure.fromJson(json['failure']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'data': data is Map<String, dynamic> ? data : data?.toString(),
      'error': error?.toString(),
      'exception': exception?.toString(),
      'statusCode':statusCode
      // 'failure': failure?.toJson(),
    };
  }
}
