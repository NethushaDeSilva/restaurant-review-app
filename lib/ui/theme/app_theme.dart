import 'package:flutter/material.dart';

const Color kSeedColour = Color(0xFFBF360C); // deep orange

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColour,
    brightness: Brightness.light,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColour,
    brightness: Brightness.dark,
  ),
);
