class SignupResponse {
  bool? status;
  int? code;
  String? message;
  SignupData? data;

  SignupResponse({this.status, this.code, this.message, this.data});

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? SignupData.fromJson(json['data']['data']) : null,
    );
  }
}

class SignupData {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? otp;
  String? updatedAt;
  String? createdAt;
  String? token;

  SignupData({this.id, this.name, this.email, this.phone, this.otp, this.updatedAt, this.createdAt, this.token});

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      otp: json['otp'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      token: json['token'],
    );
  }

}



class OtpResponse {
  final bool? status;
  final int? code;
  final String? message;
  final OtpData? data;

  OtpResponse({
     this.status,
     this.code,
     this.message,
     this.data,
  });


  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: OtpData.fromJson(json['data']),
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
  final String? otp;
  final int? expiresIn;

  OtpData({
     this.otp,
     this.expiresIn,
  });


  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      otp: json['otp'],
      expiresIn: json['expiresIn'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'expiresIn': expiresIn,
    };
  }
}


class ResetPasswordResponse {
  final bool? status;
  final int? code;
  final String? message;
  final ResetPasswordData? data;

  ResetPasswordResponse({
     this.status,
     this.code,
     this.message,
    this.data,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? ResetPasswordData.fromJson(json['data']) : null,
    );
  }

  // Method to convert an instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ResetPasswordData {
  final String id;

  ResetPasswordData({required this.id});

  factory ResetPasswordData.fromJson(Map<String, dynamic> json) {
    return ResetPasswordData(
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

