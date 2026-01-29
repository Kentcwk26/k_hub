import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/language_service.dart';

class LanguageState {
  final Locale locale;
  final String languageName;

  LanguageState({required this.locale, required this.languageName});

  LanguageState copyWith({Locale? locale, String? languageName}) {
    return LanguageState(
      locale: locale ?? this.locale,
      languageName: languageName ?? this.languageName,
    );
  }
}

class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier() : super(LanguageState(
    locale: const Locale('en'),
    languageName: 'English',
  ));

  Future<void> changeLanguage(Locale newLocale, BuildContext context) async {
    try {
      // Get the language name from supported languages
      final languageName = LanguageService.supportedLanguages[newLocale.languageCode] ?? 'English';
      
      // Update EasyLocalization
      await context.setLocale(newLocale);
      
      // Update state
      state = state.copyWith(
        locale: newLocale,
        languageName: languageName,
      );
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  void setLanguageFromDevice(Locale deviceLocale) {
    final languageName = LanguageService.supportedLanguages[deviceLocale.languageCode] ?? 'English';
    state = state.copyWith(
      locale: deviceLocale,
      languageName: languageName,
    );
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  return LanguageNotifier();
});