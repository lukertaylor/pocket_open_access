import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

ThemeData defaultThemeData(BuildContext context) {
  return ThemeData(
    colorScheme: colorScheme(),
    fontFamily: 'Roboto',
    textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
    textButtonTheme: _textButtonThemeData,
    elevatedButtonTheme: _elevatedButtonThemeData,
    textSelectionTheme: _textSelectionThemeData,
    inputDecorationTheme: _inputDecorationTheme,
    snackBarTheme: _snackBarTheme,
  );
}

ColorScheme colorScheme() {
  return const ColorScheme(
    primary: oxfordBlue,
    secondary: orange,
    surface: Colors.white,
    background: platinum,
    error: Colors.red,
    onPrimary: platinum,
    onSecondary: platinum,
    onSurface: oxfordBlue,
    onBackground: oxfordBlue,
    onError: Colors.red,
    brightness: Brightness.light,
  );
}

TextButtonThemeData get _textButtonThemeData {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

ElevatedButtonThemeData get _elevatedButtonThemeData {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
    ),
  );
}

TextSelectionThemeData get _textSelectionThemeData {
  return const TextSelectionThemeData(
    cursorColor: oxfordBlue,
    selectionColor: orange50,
    selectionHandleColor: orange50,
  );
}

InputDecorationTheme get _inputDecorationTheme {
  return InputDecorationTheme(
    errorStyle: TextStyle(color: colorScheme().error),
    enabledBorder: _outlineInputBorder(colorScheme().primary),
    focusedBorder: _outlineInputBorder(colorScheme().secondary),
    errorBorder: _outlineInputBorder(colorScheme().error),
    focusedErrorBorder: _outlineInputBorder(colorScheme().error),
    hintStyle: TextStyle(color: colorScheme().primary),
  );
}

OutlineInputBorder _outlineInputBorder(Color color) {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: color,
      width: 2.0,
    ),
    borderRadius: const BorderRadius.all(
      Radius.circular(30.0),
    ),
  );
}

SnackBarThemeData get _snackBarTheme {
  return SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        5.0,
      ),
    ),
  );
}
