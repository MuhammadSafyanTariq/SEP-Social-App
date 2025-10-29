import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/networking/urls.dart';
import 'loaderUtils.dart';
import 'package:get/get.dart';

extension GetXExtension on GetInterface {
  T add<T extends GetxController>(T Function() create) {
    try {
      return Get.find<T>();
    } catch (e) {
      return Get.put<T>(create());
    }
  }
}

extension TextEditControllerExtn on TextEditingController {
  String get getText => text.trim();
}

extension BannerAdExtension on Platform {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AdroidAds;
    } else if (Platform.isIOS) {
      return IosAds;
    }
    return '';
  }
}

extension SentDateTimeFormatter on String {
  String formatSentDateTime() {
    try {
      final dateTime = DateTime.parse(this).toLocal();
      final formattedDate = DateFormat("d, MMM yyyy").format(dateTime);
      final formattedTime = DateFormat("h:mm a").format(dateTime);
      return "$formattedDate - $formattedTime";
    } catch (e) {
      return '';
    }
  }
}

// extension MapExtn on Map {
//   List<PartValue> get partList =>
//       entries.map((data) => PartValue(data.key, data.value)).toList();
// }

// extension RxStringExtn on RxString{
//   String get getValue => value.trim();
// }

extension InExtn on int {
  String get numSuffix {
    final number = this;
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

extension NumExtn on num {
  get numToDouble => this is int ? this.toDouble() : num;

  get toDouble => this is double ? this : this.toDouble();
}

extension StringExtn on String {
  // password condition check....
  //   bool get isPassword => length > 6 && length < 25;
  bool isEquals(String value) => compareTo(value) == 0;

  bool get isPinCode {
    // if (length > 16 || length < 9) return false;

    if (length != 6) return false;
    return _hasMatch(this, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  }

  // bool get isEmail => _hasMatch(this,
  //
  //     r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{ 1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  String get getFileName {
    int lastIndex = lastIndexOf('/');
    if (lastIndex != -1 && lastIndex < length - 1) {
      return substring(lastIndex + 1);
    }
    return this;
  }

  String get getFileExtension {
    int lastIndex = lastIndexOf('.');
    if (lastIndex != -1 && lastIndex < length - 1) {
      return substring(lastIndex);
    }
    return '';
  }

  bool get isNum {
    if (trim().isEmpty) return false;
    return num.tryParse(this) is num;
  }

  int get getInt {
    if (trim().isEmpty) return 0;
    return int.tryParse(this) ?? 0;
  }

  num get getNum => num.parse(this);

  double? get getDouble => isNotNullEmpty
      ? isDouble
            ? double.parse(this)
            : null
      : null;

  String get phoneNohide => replaceRange(5, length - 2, '*' * (length - 7));

  int get agoraToken {
    final hash = sha256.convert(utf8.encode(this));
    final id = hash.bytes.sublist(0, 4).fold(0, (a, b) => a * 256 + b);
    return id;
  }
}

bool _hasMatch(String? value, String pattern) {
  return (value == null) ? false : RegExp(pattern).hasMatch(value);
}

extension OnMap on dynamic {
  bool get isDouble {
    bool result = false;
    if (this != null) {
      if (this is String) {
        result = StringExtn(toString()).isNum;
      } else if (this is num) {
        result = true;
      } else {
        result = false;
      }
    }
    return result;
  }
}

extension stringNull on String? {
  String? get fileUrl {
    if (!isNotNullEmpty) {
      return null;
    }
    final nodeUrl = this!.trim();
    final mainUrl = baseUrl;

    if (nodeUrl.contains('http')) {
      return this;
    }
    if (nodeUrl.startsWith('public')) {
      return '$mainUrl/$nodeUrl';
    }
    if (nodeUrl.startsWith('/public')) {
      return '$mainUrl$nodeUrl';
    }
    if (nodeUrl.startsWith('/')) {
      return '$mainUrl/public$nodeUrl';
    }
    return '$mainUrl/public/$nodeUrl';
  }

  bool get isPostCode => isNotNullEmpty && this!.trim().length == 6;

  bool get isNotNullEmpty => this != null && this!.trim().isNotEmpty;

  bool get isName => isNotNullEmpty;

  bool get isEmailAddress => isNotNullEmpty && this!.isEmail;

  bool get isPassword =>
      isNotNullEmpty && this!.length >= 4 && this!.length < 25;
}

// Extension for non-nullable String
extension StringExtension on String {
  bool get isNotNullEmpty => trim().isNotEmpty;

  bool get isPhone {
    // if (length > 16 || length < 9) return false;

    // if (this!.length <12 || this!.length > 16) return false;
    if (this!.length < 7
    // || this!.length > 16
    )
      return false;
    // if (this!.length != 13) return false;
    return _hasMatch(this, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  }

  String? get bearer => isNotNullEmpty ? 'Bearer $this' : null;

  DateTime? get localDateTime {
    if (isNotNullEmpty) {
      String utcString = this!;
      DateTime utcTime = DateTime.parse(utcString);
      DateTime localTime = utcTime.toLocal();
      return localTime;
    }
    return null;
  }
}

extension ListStringify<T> on List<T> {
  String stringify() {
    if (this.isEmpty) return ''; // Return empty string if the list is empty
    // Use join() to concatenate the string representations of elements
    // within the list separated by commas
    return this.map((element) => element.toString()).join(', ');
  }
}

extension FutureExtn<T> on Future<T> {
  Future<T> get applyLoader async {
    LoaderUtils.show(); // Show the loader
    try {
      return await this; // Wait for the future to complete
    } finally {
      LoaderUtils.dismiss(); // Dismiss the loader
    }
  }

  Future<T> applyLoaderWithOption(bool value) async {
    if (value) {
      return await applyLoader;
    } else {
      return this;
    }
  }
}
