class ResendOtpModel {
  final bool? status;
  final int? code;
  final String? message;
  final ResendOtpData? data;

  ResendOtpModel({
     this.status,
     this.code,
     this.message,
    this.data,
  });

  factory ResendOtpModel.fromJson(Map<String, dynamic> json) {
    return ResendOtpModel(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? ResendOtpData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ResendOtpData {
  final String? otp;
  final int? expiresIn;

  ResendOtpData({
     this.otp,
     this.expiresIn,
  });

  factory ResendOtpData.fromJson(Map<String, dynamic> json) {
    return ResendOtpData(
      otp: json['otp'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'expiresIn': expiresIn,
    };
  }
}
