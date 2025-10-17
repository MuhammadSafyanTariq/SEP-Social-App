import 'dart:convert';

class GetlistModel {
  bool? status;
  int? code;
  String? message;
  List<Template>? data;

  GetlistModel({
     this.status,
     this.code,
     this.message,
     this.data,
  });

  factory GetlistModel.fromJson(Map<String, dynamic> json) {
    return GetlistModel(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: List<Template>.from(
        json['data'].map((item) => Template.fromJson(item)),
      ),
    );
  }

  // Method to convert GetlistModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class Template {
  String? temp;
  String? type;

  Template({
     this.temp,
     this.type,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      temp: json['temp'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'type': type,
    };
  }
}

