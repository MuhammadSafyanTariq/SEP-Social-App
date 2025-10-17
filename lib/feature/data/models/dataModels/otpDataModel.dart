class OtpDataModel {
  final bool? status;
  final int? code;
  final String? message;
  final OtpData? data;

  OtpDataModel({
     this.status,
     this.code,
     this.message,
    this.data,
  });

  factory OtpDataModel.fromJson(Map<String, dynamic> json) {
    return OtpDataModel(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? OtpData.fromJson(json['data']) : null,
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

class OtpData {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? password;
  final String? otp;
  final String? otpExpiry;
  final String? deviceToken;
  final String? deviceType;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  OtpData({
     this.id,
     this.name,
     this.email,
     this.phone,
    this.password,
    this.otp,
    this.otpExpiry,
    this.deviceToken,
    this.deviceType,
    this.image,
     this.createdAt,
     this.updatedAt,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      id: json['id'] != null && json['id'].toString().isNotEmpty
          ? int.tryParse(json['id'].toString()) ?? -1
          : -1,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'],
      otp: json['otp'],
      otpExpiry: json['otpExpiry'],
      deviceToken: json['deviceToken'],
      deviceType: json['deviceType'],
      image: json['image'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'otp': otp,
      'otpExpiry': otpExpiry,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
