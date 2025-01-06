import 'dart:io';

import 'package:hiddify/gen/fonts.gen.dart';
import 'package:hiddify/gen/translations.g.dart';

extension AppLocaleX on AppLocale {
  String get preferredFontFamily => this == AppLocale.fa ? FontFamily.shabnam : (!Platform.isWindows ? "" : FontFamily.emoji);

  String get localeName => switch (flutterLocale.toString()) {
        "zh" || "zh_CN" => "中文 (中国)",
        "en" => "English",
        _ => "Unknown",
      };
}
