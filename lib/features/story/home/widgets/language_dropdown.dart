import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/locale_provider.dart';
import '../../../../utils/helper/localization_setup.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return PopupMenuButton<Locale>(
          icon: const Icon(Icons.language),
          onSelected: (Locale locale) {
            localeProvider.setLocale(locale);
          },
          itemBuilder: (BuildContext context) {
            return LocalizationSetup.supportedLocales.map((Locale locale) {
              return PopupMenuItem<Locale>(
                value: locale,
                child: Row(
                  children: [
                    if (localeProvider.locale == locale)
                      const Icon(Icons.check, color: Colors.green)
                    else
                      const SizedBox(width: 24),
                    const SizedBox(width: 8),
                    Text(_getLanguageName(locale.languageCode)),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Indonesia';
      default:
        return languageCode;
    }
  }
}
