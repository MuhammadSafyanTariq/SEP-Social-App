import 'package:get/get.dart';

import 'l10n/bnTr.dart';
import 'l10n/enTr.dart';
import 'l10n/esTr.dart';
import 'l10n/frTr.dart';
import 'l10n/zhTr.dart';


class MyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enTr,
    'fr_FR': frTr,
    'es_ES': esTr,
    'zh_CN': zhTr,
    'bn_BD': bnTr,
  };

}
