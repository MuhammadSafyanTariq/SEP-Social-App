import 'dart:convert';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const _langKey = 'language_sep';
  static const _uidKey = 'uid_sep';
  static const _userPDataKey = 'profileData_sep';
  static const _authTokenPDataKey = 'authTokenData_sep';
  static const _fcmTokenKey = 'fcmToken_sep';
  static const _uploadedImageKey = 'uploadedImage_sep';
  static const _emailKey = 'email_sep';
  static const _seemypost = 'seemypost_sep';
  static const _sharepost = 'sharepost_sep';
  static const _readNotificationsKey = 'readNotifications_sep';
  static const _pendingFollowRequestSentKey = 'pendingFollowRequestSent_sep';

  static late SharedPreferences _prefs;

  static Future<void> createInstance() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static set uid(String? uid) =>
      uid != null ? _prefs.setString(_uidKey, uid) : _prefs.remove(_uidKey);

  static String? get uid => _prefs.getString(_uidKey);

  static set email(String? email) => email != null
      ? _prefs.setString(_emailKey, email)
      : _prefs.remove(_emailKey);

  static String? get email => _prefs.getString(_emailKey);

  static set seemypost(String? email) => email != null
      ? _prefs.setString(_seemypost, email)
      : _prefs.remove(_seemypost);

  static String? get seemypost => _prefs.getString(_seemypost);

  static set shareMypost(String? email) => email != null
      ? _prefs.setString(_sharepost, email)
      : _prefs.remove(_sharepost);

  static String? get shareMypost => _prefs.getString(_sharepost);

  static set profile(ProfileDataModel? data) {
    if (data != null) {
      final json = jsonEncode(data);
      _prefs.setString(_userPDataKey, json);
    } else {
      _prefs.remove(_userPDataKey);
    }
  }

  static ProfileDataModel? get profile {
    final jsonString = _prefs.getString(_userPDataKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return ProfileDataModel.fromJson(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static set authToken(String? value) => value != null
      ? _prefs.setString(_authTokenPDataKey, value)
      : _prefs.remove(_authTokenPDataKey);

  static String? get authToken => _prefs.getString(_authTokenPDataKey);

  static bool get hasSession => authToken.isNotNullEmpty;

  static set fcmToken(String? value) => value != null
      ? _prefs.setString(_fcmTokenKey, value)
      : _prefs.remove(_fcmTokenKey);

  static String? get fcmToken => _prefs.getString(_fcmTokenKey);

  static set savePrefOnLogin(ProfileDataModel? data) {
    profile = data;
    uid = data?.id;
    // authToken = data?.authToken;
  }

  static set savePrefOnSocialLogin(ProfileDataModel? data) {
    profile = data;
    uid = data?.id;
    // authToken = data?.authToken;
  }

  static Future<void> onLogout() async {
    uid = null;
    profile = null;
    authToken = null;
    fcmToken = null;
    uploadedImage = null;
    clearReadNotificationIds();
    clearPendingFollowRequestSentIds();
  }

  /// User IDs we've sent a follow request to (private accounts). Persisted so "Requested" state survives navigation.
  static Set<String> get pendingFollowRequestSentToIds {
    final jsonString = _prefs.getString(_pendingFollowRequestSentKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.cast<String>().toSet();
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static set _pendingFollowRequestSentToIds(Set<String> ids) {
    _prefs.setString(_pendingFollowRequestSentKey, jsonEncode(ids.toList()));
  }

  static void addPendingFollowRequestSent(String userId) {
    final set = pendingFollowRequestSentToIds;
    set.add(userId);
    _pendingFollowRequestSentToIds = set;
  }

  static void removePendingFollowRequestSent(String userId) {
    final set = pendingFollowRequestSentToIds;
    set.remove(userId);
    _pendingFollowRequestSentToIds = set;
  }

  static void clearPendingFollowRequestSentIds() {
    _prefs.remove(_pendingFollowRequestSentKey);
  }

  static set language(String? value) => value != null
      ? _prefs.setString(_langKey, value)
      : _prefs.remove(_langKey);

  static String? get language => _prefs.getString(_langKey);

  static set uploadedImage(String? imageUrl) => imageUrl != null
      ? _prefs.setString(_uploadedImageKey, imageUrl)
      : _prefs.remove(_uploadedImageKey);

  static String? get uploadedImage => _prefs.getString(_uploadedImageKey);

  static String? getImage() => _prefs.getString(_uploadedImageKey);

  static Future<void> clearAuthData() async {
    await Preferences._prefs.remove(Preferences._authTokenPDataKey);
    await Preferences._prefs.remove(Preferences._uidKey);
  }

  static Future<void> clearLanguage() async {
    await Preferences._prefs.remove(Preferences._langKey);
  }

  static Future<void> clearUploadedImage() async {
    await Preferences._prefs.remove(Preferences._uploadedImageKey);
  }

  static Future<void> clearUserData() async {
    uid = null;
    profile = null;
    authToken = null;
    uploadedImage = null;

    // await _prefs.remove(_uidKey);
    // await _prefs.remove(_userPDataKey);
    // await _prefs.remove(_authTokenPDataKey);
    // await _prefs.remove(_fcmTokenKey);
    // await _prefs.remove(_uploadedImageKey);
    // await _prefs.clear();
  }

  // Read notification IDs management
  static Set<String> get readNotificationIds {
    final jsonString = _prefs.getString(_readNotificationsKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.cast<String>().toSet();
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static set readNotificationIds(Set<String> ids) {
    final jsonString = jsonEncode(ids.toList());
    _prefs.setString(_readNotificationsKey, jsonString);
  }

  static void addReadNotificationId(String id) {
    final currentIds = readNotificationIds;
    currentIds.add(id);
    readNotificationIds = currentIds;
  }

  static void clearReadNotificationIds() {
    _prefs.remove(_readNotificationsKey);
  }
}
