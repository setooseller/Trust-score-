// Minimal bilingual string helper for Hindi and English application text.
import 'package:flutter/material.dart';

class AppStrings {
  static const List<Locale> supportedLocales = <Locale>[
    Locale('hi'),
    Locale('en'),
  ];

  static String of(BuildContext context, {required String hi, required String en}) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'hi' ? hi : en;
  }
}
