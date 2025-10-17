import 'package:sep/utils/extensions/extensions.dart';

class FormValidation{
  static String?  userName(String value){
    return value.isNotNullEmpty ? null : 'Please enter name';
  }
}