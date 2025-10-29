// import '../../../../services/storage/preferences.dart';
// import '../../../domain/requestEntities/registerRequestEntity.dart';
//
// class RegisterRequestModel extends RegisterRequestEntity {
//   String? fullName;
//   String? password;
//  String? oldPassword;
//   String? deviceType;
//   String? deviceToken;
//   String? email;
//   String? mobileNumber;
//
//
//   RegisterRequestModel(
//       {this.mobileNumber,
//       this.email,
//       this.oldPassword,
//       this.deviceToken,
//       this.deviceType,
//       this.fullName,
//       this.password,
//       })
//       : super(
//           email: email,
//           oldPassword: oldPassword,
//           mobileNumber: mobileNumber,
//           deviceToken: deviceToken,
//           deviceType: deviceType,
//           fullName: fullName,
//           password: password,
//
//         );
//
//   String get getDeviceToken => '1234567654324565434543454345675434567654';
//
//
//   Map<String, dynamic> toChangePasswordJsonRequest()=>{
//     "old_password": oldPassword,
//     "new_password": password,
//   };
//
//
//   Map<String, dynamic> toForgotPasswordJsonRequest()=>{
//   "email": email
//   };
//
//
//   Map<String, dynamic> toLoginJsonRequest()=>{
//     "email": email,
//     "password": password,
//     // "device_type": AppUtils.,
//     "device_token": Preferences.fcmToken,
//   };
//
//   Map<String, dynamic> toUpdatePatientJsonRequest()=>{
//   'full_name':fullName,
//   'email':email,
//   'mobile_number':mobileNumber,
//     // 'latitude': 0.0,
//     // 'longitude': 0.0,
//   };
//
//   Map<String, dynamic> toUpdateClinicJsonRequest()=>{
//     'full_name':fullName,
//     'email':email,
//     'mobile_number':mobileNumber,
//
//     // ..._slotsTimeJson(),
//   };
//
//
//   // full_name:clinic6
//   // user_type:clinic
//   // email:clinic10@example.com
//   // mobile_number:878645254364
//   // clinic_type:Eye Clinic
//   // postal_code:123456
//   // city:test
//   // address:test
//   // specialties_services:test
//   // operating_hours:mon,tue,sat
//   // website:
//   // license_number:
//   // latitude:34324
//   // longitude:423434
//   //
//   // Map<String,String> _slotsTimeJson() => openingDaysSlot != null ? openingDaysSlot! : {};
//   // Map<String, dynamic> toClinicJsonRequest() => {
//   //       'full_name': fullName,
//   //       'password': password,
//   //   "device_token": Preferences.fcmToken,
//   //       'email': email,
//   //       'mobile_number': mobileNumber,
//   //       ..._slotsTimeJson(),
//   //     };
//   //
//   // Map<String, dynamic> toPatientJsonRequest() => {
//   //       'full_name': fullName,
//   //       'password': password,
//   //   "device_token": Preferences.fcmToken,
//   //       'email': email,
//   //       'mobile_number': mobileNumber,
//   //   'latitude': 0.0,
//   //    'longitude': 0.0,
//   //     // 'latitude': lat,
//   //     //  'longitude': lng,
//   //       // 'profile_pic': profilePic,
//   //     };
//   //
//   // Map<String, dynamic> toSocialLoginRequest() => {
//   // "full_name" : fullName,
//   // "email" : email,
//   // "device_token" :  Preferences.fcmToken,
//   // "auth_id" : socialAuthId
//   // };
//
//
// //   {
// //     "full_name" : "social user",
// //   "email" : "social@gmail.com",
// //   "user_type" : "clinic",
// //   "device_type" : "android",
// //   "device_token" : "34q34345345",
// //   "login_type" : "gmail",
// //   "auth_id" : "12345"
// // }
//
//
// }
