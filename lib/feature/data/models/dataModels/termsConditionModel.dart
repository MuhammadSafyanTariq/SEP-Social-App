class TermsConditionModel {
  final bool? status;
  final int? code;
  final String? message;
  final TermsConditionData? data;

  TermsConditionModel({
     this.status,
     this.code,
     this.message,
    this.data,
  });

  factory TermsConditionModel.fromJson(Map<String, dynamic> json) {
    return TermsConditionModel(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? TermsConditionData.fromJson(json['data'])
          : null,
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

class TermsConditionData {
  final int? id;
  final String? title;
  final String? description;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TermsConditionData({
     this.id,
     this.title,
     this.description,
     this.type,
     this.createdAt,
     this.updatedAt,
  });

  factory TermsConditionData.fromJson(Map<String, dynamic> json) {
    return TermsConditionData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
