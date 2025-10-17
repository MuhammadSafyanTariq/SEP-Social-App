// import 'dart:convert';
//
// // import 'package:kioski/core/model/menuModel.dart';
// // import 'package:kioski/feature/data/models/dataModels/userProfileDataModel.dart';
// // import 'package:kioski/feature/presentation/controller/languageCtrl.dart';
// // import 'package:kioski/utils/extensions/extensions.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../components/constants.dart';
//
// class Preferences {
//   static const _langKey = 'language_Koski';
//   static const _uidKey = 'uid_Koski';
//   static const _userRoleKey = 'userRole_Koski';
//   static const _userPDataKey = 'profileData_Koski';
//   static const _authTokenPDataKey = 'authTokenData_Koski';
//   static const _fcmTokenKey = 'fcmToken_Koski';
//   static const _notificationSettingsKey = 'notificationSettings_Koski';
//
//   static late SharedPreferences _prefs;
//
//   static Future createInstance() async {
//     _prefs = await SharedPreferences.getInstance();
//     return;
//   }
//
//   static set notificationSettings(List<MenuModel> list){
//     List<String>? data;
//     for(var item in list){
//       if(item.status ?? false){
//         data ??= [];
//         data.add(item.key);
//       }
//     }
//     final value = data?.stringify(joinPattern: ',');
//     value != null ? _prefs.setString(_notificationSettingsKey, value) : _prefs.remove(_notificationSettingsKey);
//   }
//
//   static List<String> notificationSetting(){
//     List<String> list = [];
//    final String? data = _prefs.getString(_uidKey);
//    if(data != null){
//     list = data.split(',');
//    }
//     return list;
//   }
//
//   //-----------------[uid]-----------------------------------------------
//   static set setUid(String? uid) =>
//       uid != null ? _prefs.setString(_uidKey, uid) : _prefs.remove(_uidKey);
//
//   static String? get getUid => _prefs.getString(_uidKey);
//
//
//   static set setFcmToken(String? token) =>
//       token != null ? _prefs.setString(_fcmTokenKey, token) : _prefs.remove(_fcmTokenKey);
//
//   static String? get getFcmToken => _prefs.getString(_fcmTokenKey);
//
//   //-----------------[UserRole]-----------------------------------------------
//   static set setUserRole(UserRole? role) => role != null
//       ? _prefs.setString(_userRoleKey, role.name)
//       : _prefs.remove(_userRoleKey);
//
//   static UserRole? get getUserRole =>
//       _prefs.getString(_userRoleKey)?.getUserRole;
//
//   //-----------------[User Profile]-----------------------------------------------
//   static set setProfile(UserProfileDataModel? data)  {
//     if(data != null){
//       final json = jsonEncode(data);
//       _prefs.setString(_userPDataKey, json);
//     }else{
//       _prefs.remove(_userPDataKey);
//     }
// }
//
//   static UserProfileDataModel? get getProfile {
//     String? value = _prefs.getString(_userPDataKey);
//     if (value != null) {
//       try {
//         final json = jsonDecode(value);
//         return UserProfileDataModel.fromJsonPreferences(json);
//       } catch (e) {
//         return null;
//       }
//     } else {
//       return null;
//     }
//   }
//
//   static bool get isTeamMember{
//     final data = getProfile;
//     if(data == null) return false;
//     return data.isTeamMember ?? false;
//   }
//
//
//   static String? get getTeamLeadId {
//     final data = getProfile;
//     if(data == null) return null;
//
//     return  data.teamLeadId;
//   }
//
//
//   static bool get hasSession{
//     return getAuthToken.isNotNullEmpty;
//   }
//
//   //-----------------[LocaleEnum]-----------------------------------------------
//   static set setLocale(LocaleEnum value) =>
//       _prefs.setString(_langKey, value.name);
//
//   static LocaleEnum? get getLocale {
//     String? value = _prefs.getString(_langKey);
//     return value != null
//         ? value == 'en'
//             ? LocaleEnum.en
//             : LocaleEnum.hi
//         : null;
//   }
//
//   //-----------------[Auth Token]-----------------------------------------------
//
//   static set setAuthToken(String? value) =>
//       value != null ? _prefs.setString(_authTokenPDataKey, value) : _prefs.remove(_authTokenPDataKey);
//
//   static String get getAuthToken {
//     String? value = _prefs.getString(_authTokenPDataKey);
//     return value ?? '';
//   }
//
//
//   static get isAuthenticated => getUid.isNotNullEmpty && getAuthToken.isNotNullEmpty;
//
//
//   static onLogout() {
//     setUid = null;
//     setUserRole = null;
//     setProfile = null;
//     setAuthToken = null;
//     notificationSettings = [];
//   }
// }
