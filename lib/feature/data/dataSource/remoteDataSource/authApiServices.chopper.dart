// part of 'authApiServices.dart';
// // **************************************************************************
// // ChopperGenerator
// // **************************************************************************
//
// // import 'package:chopper/chopper.dart';
// //
// // import 'authApiServices.dart';
//
// final class _$AuthApiServices extends AuthApiServices {
//   _$AuthApiServices([ChopperClient? client]) {
//     if (client == null) return;
//     this.client = client;
//   }
//
//   @override
//   final Type definitionType = AuthApiServices;
//
//   @override
//   Future<Response<dynamic>> registration({
//     required List<PartValue<dynamic>> data,
//     required String? profileImage,
//   }) {
//     final Uri $url = Uri.parse('/user/register');
//     final List<PartValue> $parts = <PartValue>[
//       PartValueFile<String?>(
//         'profile_pic',
//         profileImage,
//       )
//     ];
//     $parts.addAll(data);
//     final Request $request = Request(
//       'GET',
//       $url,
//       client.baseUrl,
//       parts: $parts,
//       multipart: true,
//     );
//     return client.send<dynamic, dynamic>($request);
//   }
// }
