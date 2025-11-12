class JobModel {
  final String? id;
  final String? userId;
  final String jobTitle;
  final String country;
  final String city;
  final String jobType;
  final String description;
  final String contact;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JobModel({
    this.id,
    this.userId,
    required this.jobTitle,
    required this.country,
    required this.city,
    required this.jobType,
    required this.description,
    required this.contact,
    this.createdAt,
    this.updatedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['_id'],
      userId: json['userId'],
      jobTitle: json['jobTitle'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      jobType: json['jobType'] ?? '',
      description: json['description'] ?? '',
      contact: json['contact'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (userId != null) 'userId': userId,
      'jobTitle': jobTitle,
      'country': country,
      'city': city,
      'jobType': jobType,
      'description': description,
      'contact': contact,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  JobModel copyWith({
    String? id,
    String? userId,
    String? jobTitle,
    String? country,
    String? city,
    String? jobType,
    String? description,
    String? contact,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jobTitle: jobTitle ?? this.jobTitle,
      country: country ?? this.country,
      city: city ?? this.city,
      jobType: jobType ?? this.jobType,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LocationModel {
  final double lat;
  final double long;
  final String address;
  final String city;

  LocationModel({
    required this.lat,
    required this.long,
    required this.address,
    required this.city,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      long: (json['long'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'long': long, 'address': address, 'city': city};
  }
}

enum JobType {
  fullTime('full-time'),
  partTime('part-time'),
  contract('contract'),
  freelance('freelance'),
  internship('internship');

  const JobType(this.value);
  final String value;

  static JobType fromString(String value) {
    return JobType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => JobType.fullTime,
    );
  }
}
