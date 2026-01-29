import 'package:flutter/material.dart';

class ElevatedButtonVariants {
  static ButtonStyle _baseStyle(Color background, Color foreground) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(background),
      foregroundColor: WidgetStateProperty.all(foreground),
      overlayColor: WidgetStateProperty.all(background.withOpacity(0.9)),
      padding: WidgetStateProperty.all(const EdgeInsets.all(20)),
    );
  }

  static Widget _build({
    required Color background,
    required Color foreground,
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
  }) {
    final style = _baseStyle(background, foreground);

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: child,
        style: style,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }

  static Widget success({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
  }) =>
      _build(
        background: Colors.green,
        foreground: Colors.white,
        onPressed: onPressed,
        child: child,
        icon: icon,
      );

  static Widget warning({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
  }) =>
      _build(
        background: Colors.orange,
        foreground: Colors.white,
        onPressed: onPressed,
        child: child,
        icon: icon,
      );

  static Widget danger({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
  }) =>
      _build(
        background: Colors.red,
        foreground: Colors.white,
        onPressed: onPressed,
        child: child,
        icon: icon,
      );

  static Widget info({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
  }) =>
      _build(
        background: Colors.blue,
        foreground: Colors.white,
        onPressed: onPressed,
        child: child,
        icon: icon,
      );

  static Widget disable({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
  }) =>
      _build(
        background: Colors.grey,
        foreground: Colors.white,
        onPressed: onPressed,
        child: child,
        icon: icon,
      );

  static Widget auto({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
  }) {
    final isEnabled = onPressed != null;
    return _build(
      background: isEnabled ? Colors.green : Colors.grey,
      foreground: Colors.white,
      onPressed: onPressed,
      child: child,
      icon: icon,
    );
  }
}