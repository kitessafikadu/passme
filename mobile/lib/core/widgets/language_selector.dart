import 'package:flutter/material.dart';

enum Language { english, amharic, turkish }

extension LanguageExtension on Language {
  String get code {
    switch (this) {
      case Language.english:
        return 'english';
      case Language.amharic:
        return 'amharic';
      case Language.turkish:
        return 'turkish';
    }
  }
}

class LanguageSelector extends StatelessWidget {
  final Language selectedLanguage;
  final ValueChanged<Language> onChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = Language.values
        .map((lang) => DropdownMenuItem(
              value: lang,
              child: Text(
                _getLanguageName(lang),
                style: const TextStyle(color: Colors.white),
              ),
            ))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0Xff676470)),
        color: Color(0Xff676470),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<Language>(
        value: selectedLanguage,
        dropdownColor: const Color(0Xff676470),
        iconEnabledColor: Colors.white,
        underline: const SizedBox(),
        onChanged: (Language? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: options,
      ),
    );
  }

  String _getLanguageName(Language lang) {
    switch (lang) {
      case Language.english:
        return 'English';
      case Language.amharic:
        return 'አማርኛ';
      case Language.turkish:
        return "Türkçe";
    }
  }
}
