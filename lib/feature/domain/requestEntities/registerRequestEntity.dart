// import 'package:bumbaja/utils/extensions/extensions.dart';
// import 'package:get/get.dart';
//
// import '../../data/models/requestModels/registerRequestModel.dart';
//
// class RegisterRequestEntity {
//   String? fullName;
//   String? oldPassword;
//   String? password;
//   String? confPassword;
//   String? deviceType;
//   String? deviceToken;
//   String? email;
//   String? mobileNumber;
//
//   RegisterRequestEntity(
//       {
//         this.mobileNumber,
//         this.email,
//         this.oldPassword,
//         this.confPassword,
//         this.password,
//       this.deviceToken,
//       this.deviceType,
//       this.fullName,
//
//       });
//
//   bool get isValidChangePassword => oldPassword.isNotNullEmpty &&
//       password.isPassword && confPassword!.compareTo(password!) == 0;
//
//   bool get isEmailValid => email.isNotNullEmpty && email!.isEmail;
//
//   bool get isValidClinic =>
//       fullName.isName &&
//       password.isPassword &&
//       email.isNotNullEmpty &&
//       email!.isEmail &&
//       password!.trim().compareTo(confPassword!.trim()) == 0;
//
//
//   bool get isValidLogin => email.isNotNullEmpty && email!.isEmail && password.isPassword;
//
//   RegisterRequestEntity get loginError => RegisterRequestEntity(
//       email: email.isNotNullEmpty && email!.isEmail ? null : 'Please enter email',
//       password: password.isPassword ? null : 'Please enter password'
//   );
//
//   RegisterRequestEntity get changePasswordError => RegisterRequestEntity(
//     oldPassword: oldPassword.isNotNullEmpty? null : 'Please enter your password',
//     password: password.isPassword ? null : 'Please enter valid new password',
//     confPassword: password!.compareTo(confPassword!) == 0 ? null : 'Password do not match',
//   );
//
//   RegisterRequestEntity get passwordError => RegisterRequestEntity(
//         password: password.isPassword ? null : 'Please enter your password',
//         fullName: fullName.isName ? null : 'Please enter name',
//         mobileNumber:
//             mobileNumber.isPhone ? null : 'Please enter valid phone number',
//         email: email.isNotNullEmpty && email!.isEmail
//             ? null
//             : 'Please enter valid email address',
//     confPassword: confPassword == null || confPassword!.trim().isEmpty
//         ? 'Please enter confirm password'
//         : password == null || password?.trim() != confPassword?.trim()
//         ? 'Passwords do not match'
//         : null,
//
//       );
//
//   RegisterRequestModel get model => RegisterRequestModel(
//       email: email,
//       mobileNumber: mobileNumber,
//       fullName: fullName,
//       password: password,
//       oldPassword: oldPassword,
//     // confPassword: confPassword,
//     deviceToken: deviceToken,
//     deviceType: deviceType,
//   );
// }
