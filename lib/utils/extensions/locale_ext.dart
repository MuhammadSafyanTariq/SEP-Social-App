// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//
// import '../../main.dart';
//
// AppLocalizations? get tr => navState.currentContext?.locale;
//
//
// extension LocaleExt on BuildContext{
//   AppLocalizations? get locale => AppLocalizations.of(this);
//   // AppLocalizations? get locale => Localizations.of<AppLocalizations>(this,AppLocalizations);
//   Future<AppLocalizations> get localeEn => AppLocalizations.delegate.load(const Locale('en'));
//   Future<AppLocalizations> get localeFr => AppLocalizations.delegate.load(const Locale('fr'));
//   Future<AppLocalizations> get localePt => AppLocalizations.delegate.load(const Locale('pt'));
//   bool get isPt => locale?.lang == 'pt';
//   bool get isEn => locale?.lang == 'en';
//   bool get isFr => locale?.lang == 'fr';
// }