import 'package:flutter/material.dart';
import 'dart:developer';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get size => MediaQuery.sizeOf(this);

  double get height => size.height;

  double get width => size.width;

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  double get safeAreaTop => mediaQuery.padding.top;

  double get safeAreaBottom => mediaQuery.padding.bottom;

  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  Orientation get orientation => mediaQuery.orientation;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  double get textScaleFactor => mediaQuery.textScaleFactor;
}
