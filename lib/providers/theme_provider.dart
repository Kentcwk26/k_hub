import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/theme_service.dart';

class ThemeState {
  final String themeName;
  final Color primaryColor;
  final Color secondaryColor;
  final Color scaffoldBackgroundColor;
  final Color appBarColor;

  ThemeState({
    required this.themeName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.scaffoldBackgroundColor,
    required this.appBarColor,
  });

  bool get isDarkMode {
    final double luminance = (scaffoldBackgroundColor.computeLuminance() + appBarColor.computeLuminance()) / 2;
    return luminance < 0.5;
  }

  ThemeState copyWith({
    String? themeName,
    Color? primaryColor,
    Color? secondaryColor,
    Color? scaffoldBackgroundColor,
    Color? appBarColor,
  }) {
    return ThemeState(
      themeName: themeName ?? this.themeName,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      appBarColor: appBarColor ?? this.appBarColor,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(
          themeName: 'Default',
          primaryColor: const Color(0xFFf0d87f),
          secondaryColor: const Color(0xFFd4be6f),
          scaffoldBackgroundColor: const Color(0xFFFDF6E3),
          appBarColor: const Color(0xFFf0d87f),
        )) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final savedTheme = await ThemeService.getTheme();
    final savedPrimary = await ThemeService.getPrimaryColor();
    final savedSecondary = await ThemeService.getSecondaryColor();
    final savedScaffold = await ThemeService.getScaffoldBackgroundColor();
    final savedAppBar = await ThemeService.getAppBarColor();

    if (savedTheme != null) {
      state = state.copyWith(themeName: savedTheme);
    }

    if (savedPrimary != null) {
      state = state.copyWith(primaryColor: Color(savedPrimary));
    }

    if (savedSecondary != null) {
      state = state.copyWith(secondaryColor: Color(savedSecondary));
    }

    if (savedScaffold != null) {
      state = state.copyWith(scaffoldBackgroundColor: Color(savedScaffold));
    }

    if (savedAppBar != null) {
      state = state.copyWith(appBarColor: Color(savedAppBar));
    }
  }

  void changeTheme(String themeName, {Color? primaryColor, Color? secondaryColor, Color? scaffoldBackground, Color? appBarColor}) {
    Color newPrimary = primaryColor ?? state.primaryColor;
    Color newSecondary = secondaryColor ?? state.secondaryColor;
    Color newScaffold = scaffoldBackground ?? state.scaffoldBackgroundColor;
    Color newAppBar = appBarColor ?? state.appBarColor;

    switch (themeName) {
      case 'Pink':
        newPrimary = const Color(0xFFE91E63);
        newSecondary = const Color(0xFFF8BBD0);
        newScaffold = const Color(0xFFFCE4EC);
        newAppBar = const Color(0xFFE91E63);
        break;
      case 'Purple':
        newPrimary = const Color(0xFF9C27B0);
        newSecondary = const Color(0xFFE1BEE7);
        newScaffold = const Color(0xFFF3E5F5);
        newAppBar = const Color(0xFF9C27B0);
        break;
      case 'Blue':
        newPrimary = const Color(0xFF2196F3);
        newSecondary = const Color(0xFFBBDEFB);
        newScaffold = const Color(0xFFE3F2FD);
        newAppBar = const Color(0xFF2196F3);
        break;
      case 'Green':
        newPrimary = const Color(0xFF4CAF50);
        newSecondary = const Color(0xFFC8E6C9);
        newScaffold = const Color(0xFFE8F5E8);
        newAppBar = const Color(0xFF4CAF50);
        break;
      case 'Custom':
        break;
      default:
        newPrimary = const Color(0xFFf0d87f);
        newSecondary = const Color(0xFFd4be6f);
        newScaffold = const Color(0xFFFDF6E3);
        newAppBar = const Color(0xFFf0d87f);
    }

    state = state.copyWith(
      themeName: themeName,
      primaryColor: newPrimary,
      secondaryColor: newSecondary,
      scaffoldBackgroundColor: newScaffold,
      appBarColor: newAppBar,
    );

    // Save to shared preferences
    ThemeService.saveTheme(themeName);
    ThemeService.savePrimaryColor(newPrimary.value);
    ThemeService.saveSecondaryColor(newSecondary.value);
    ThemeService.saveScaffoldBackgroundColor(newScaffold.value);
    ThemeService.saveAppBarColor(newAppBar.value);
  }

  void setCustomColors(Color primary, Color secondary, Color scaffold, Color appBar) {
    state = state.copyWith(
      themeName: 'Custom',
      primaryColor: primary,
      secondaryColor: secondary,
      scaffoldBackgroundColor: scaffold,
      appBarColor: appBar,
    );

    ThemeService.saveTheme('Custom');
    ThemeService.savePrimaryColor(primary.value);
    ThemeService.saveSecondaryColor(secondary.value);
    ThemeService.saveScaffoldBackgroundColor(scaffold.value);
    ThemeService.saveAppBarColor(appBar.value);
  }

  void setScaffoldBackgroundColor(Color color) {
    state = state.copyWith(scaffoldBackgroundColor: color);
    ThemeService.saveScaffoldBackgroundColor(color.value);
  }

  void setAppBarColor(Color color) {
    state = state.copyWith(appBarColor: color);
    ThemeService.saveAppBarColor(color.value);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});