//
// import 'package:chopper/chopper.dart';
//
// import '../../../../services/network/urls.dart';
//
// @ChopperApi(baseUrl: Urls.userCollection)
// abstract class AuthApiServices extends ChopperService {
//
//   static AuthApiServices create([ChopperClient? client]) =>
//       _$AuthApiServices(client);
//
//   @Multipart()
//   @Post(path: Urls.registration)
//   Future<Response> register({
//     @PartMap() required Map<String, dynamic> data,
//   });
// }
