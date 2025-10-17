class TemplateModel {
  final bool? status;
  final int? code;
  final String? message;
  final TemplateData? data;

  TemplateModel({
     this.status,
     this.code,
     this.message,
     this.data,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: TemplateData.fromJson(json['data']),
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

class TemplateData {
  final int? id;
  final String? type;
  final String? name;
  final String? description;
  final String? htmlContent;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  TemplateData({
     this.id,
     this.type,
     this.name,
     this.description,
     this.htmlContent,
     this.updatedAt,
     this.createdAt,
  });

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      description: json['description'],
      htmlContent: json['htmlContent'],
      updatedAt: DateTime.parse(json['updatedAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'htmlContent': htmlContent,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
