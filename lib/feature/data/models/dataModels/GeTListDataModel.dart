// <<<<<<< HEAD
// // class GeTListDataModel {
// //   bool status;
// //   int code;
// //   String message;
// //   List<PostData> data;
// //
// //   GeTListDataModel({
// //     required this.status,
// //     required this.code,
// //     required this.message,
// //     required this.data,
// //   });
// //
// //   factory GeTListDataModel.fromJson(Map<String, dynamic> json) {
// //     return GeTListDataModel(
// //       status: json['status'] ?? false,
// //       code: json['code'] ?? 0,
// //       message: json['message'] ?? '',
// //       // data: (json['data'] != null && json['data']['data'] != null)
// //       //     ? List<PostData>.from(json['data']['data'].map((x) => PostData.fromJson(x)))
// //       //     : [],
// //       data: (json['data'] is List)
// //           ? List<PostData>.from(json['data'].map((x) => PostData.fromJson(x)))
// //           : (json['data']?['data'] != null)
// //           ? List<PostData>.from(json['data']['data'].map((x) => PostData.fromJson(x)))
// //           : [],
// //
// //     );
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'status': status,
// //       'code': code,
// //       'message': message,
// //       'data': {'data': List<dynamic>.from(data.map((x) => x.toJson()))},
// //     };
// //   }
// // }
// //
// //
// // class PostData {
// //   Location location;
// //   String id;
// //   String userId;
// //   String categoryId;
// //   String content;
// //   List<FileData> files;
// //   String fileType;
// //   String createdAt;
// //   String updatedAt;
// //   int v;
// //
// //   PostData({
// //     required this.location,
// //     required this.id,
// //     required this.userId,
// //     required this.categoryId,
// //     required this.content,
// //     required this.files,
// //     required this.fileType,
// //     required this.createdAt,
// //     required this.updatedAt,
// //     required this.v,
// //   });
// //
// //   factory PostData.fromJson(Map<String, dynamic> json) {
// //     return PostData(
// //       location: Location.fromJson(json['location']),
// //       id: json['_id'],
// //       userId: json['userId'],
// //       categoryId: json['categoryId'],
// //       content: json['content'],
// //       files: List<FileData>.from(json['files'].map((x) => FileData.fromJson(x))),
// //       fileType: json['fileType'],
// //       createdAt: json['createdAt'],
// //       updatedAt: json['updatedAt'],
// //       v: json['__v'] ?? 0,
// //     );
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'location': location.toJson(),
// //       '_id': id,
// //       'userId': userId,
// //       'categoryId': categoryId,
// //       'content': content,
// //       'files': List<dynamic>.from(files.map((x) => x.toJson())),
// //       'fileType': fileType,
// //       'createdAt': createdAt,
// //       'updatedAt': updatedAt,
// //       '__v': v,
// //     };
// //   }
// // }
// //
// // class Location {
// //   String type;
// //   List<double> coordinates;
// //
// //   Location({
// //     required this.type,
// //     required this.coordinates,
// //   });
// //
// //   factory Location.fromJson(Map<String, dynamic> json) {
// //     return Location(
// //       type: json['type'],
// //       coordinates: List<double>.from(json['coordinates'].map((x) => x.toDouble())),
// //     );
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'type': type,
// //       'coordinates': List<dynamic>.from(coordinates.map((x) => x)),
// //     };
// //   }
// // }
// //
// //
// //
// // class FileData {
// //   String file;
// //   String type;
// //   String id;
// //
// //   FileData({
// //     required this.file,
// //     required this.type,
// //     required this.id,
// //   });
// //
// //   factory FileData.fromJson(Map<String, dynamic> json) {
// //     return FileData(
// //       file: json['file'],
// //       type: json['type'],
// //       id: json['_id'],
// //     );
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'file': file,
// //       'type': type,
// //       '_id': id,
// //     };
// //   }
// // }
// =======
// class GeTListDataModel {
//   bool status;
//   int code;
//   String message;
//   List<PostData> data;
//
//   GeTListDataModel({
//     required this.status,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory GeTListDataModel.fromJson(Map<String, dynamic> json) {
//     return GeTListDataModel(
//       status: json['status'] ?? false,
//       code: json['code'] ?? 0,
//       message: json['message'] ?? '',
//       // data: (json['data'] != null && json['data']['data'] != null)
//       //     ? List<PostData>.from(json['data']['data'].map((x) => PostData.fromJson(x)))
//       //     : [],
//       data: (json['data'] is List)
//           ? List<PostData>.from(json['data'].map((x) => PostData.fromJson(x)))
//           : (json['data']?['data'] != null)
//           ? List<PostData>.from(json['data']['data'].map((x) => PostData.fromJson(x)))
//           : [],
//
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'code': code,
//       'message': message,
//       'data': {'data': List<dynamic>.from(data.map((x) => x.toJson()))},
//     };
//   }
// }
//
//
// class PostData {
//   Location location;
//   String id;
//   String userId;
//   String categoryId;
//   String content;
//   List<FileData> files;
//   String fileType;
//   String createdAt;
//   String updatedAt;
//   int v;
//
//   PostData({
//     required this.location,
//     required this.id,
//     required this.userId,
//     required this.categoryId,
//     required this.content,
//     required this.files,
//     required this.fileType,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.v,
//   });
//
//   factory PostData.fromJson(Map<String, dynamic> json) {
//     return PostData(
//       location: Location.fromJson(json['location']),
//       id: json['_id'],
//       userId: json['userId'],
//       categoryId: json['categoryId'],
//       content: json['content'],
//       files: List<FileData>.from(json['files'].map((x) => FileData.fromJson(x))),
//       fileType: json['fileType'],
//       createdAt: json['createdAt'],
//       updatedAt: json['updatedAt'],
//       v: json['__v'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'location': location.toJson(),
//       '_id': id,
//       'userId': userId,
//       'categoryId': categoryId,
//       'content': content,
//       'files': List<dynamic>.from(files.map((x) => x.toJson())),
//       'fileType': fileType,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//       '__v': v,
//     };
//   }
// }
//
// class Location {
//   String type;
//   List<double> coordinates;
//
//   Location({
//     required this.type,
//     required this.coordinates,
//   });
//
//   factory Location.fromJson(Map<String, dynamic> json) {
//     return Location(
//       type: json['type'],
//       coordinates: List<double>.from(json['coordinates'].map((x) => x.toDouble())),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'type': type,
//       'coordinates': List<dynamic>.from(coordinates.map((x) => x)),
//     };
//   }
// }
//
//
//
// class FileData {
//   String file;
//   String type;
//   String id;
//
//   FileData({
//     required this.file,
//     required this.type,
//     required this.id,
//   });
//
//   factory FileData.fromJson(Map<String, dynamic> json) {
//     return FileData(
//       file: json['file'],
//       type: json['type'],
//       id: json['_id'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'file': file,
//       'type': type,
//       '_id': id,
//     };
//   }
// }
// >>>>>>> 4e74444032fe00d1b74968b3216ab253a048319f
