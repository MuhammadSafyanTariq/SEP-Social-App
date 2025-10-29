class GetUserDetailModel {
  bool? status;
  int? code;
  String? message;
  UserData? data;

  GetUserDetailModel({
     this.status,
     this.code,
     this.message,
     this.data,
  });

  factory GetUserDetailModel.fromJson(Map<String, dynamic> json) {
    return GetUserDetailModel(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
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

class UserData {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? password;
  String? otp;
  String? otpExpiry;
  String? deviceToken;
  String? socialId;
  String? socialType;
  String? deviceType;
  String? image;
  String? createdAt;
  String? updatedAt;

  UserData({
     this.id,
     this.name,
     this.email,
     this.phone,
     this.password,
    this.otp,
    this.otpExpiry,
    this.deviceToken,
    this.socialId,
    this.socialType,
    this.deviceType,
     this.image,
     this.createdAt,
     this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
      otp: json['otp'],
      otpExpiry: json['otpExpiry'],
      deviceToken: json['deviceToken'],
      socialId: json['social_Id'],
      socialType: json['socialType'],
      deviceType: json['deviceType'],
      image: json['image'] ?? '',
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
      'social_Id': socialId,
      'socialType': socialType,
      'deviceType': deviceType,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

