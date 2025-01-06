import 'package:hiddify/core/localization/translations.dart';

enum Region {
  ir,
  cn,
  ru,
  af,
  id,
  tr,
  br,
  other;

  String present(TranslationsEn t) => switch (this) {
        cn => t.settings.general.regions.cn,
        other => t.settings.general.regions.other,
      };
}
