import 'package:flutter/material.dart';

/// One seed colour generates the whole palette for both modes.
///
/// ColorScheme.fromSeed builds a full Material 3 palette from this single
/// colour and guarantees the text-on-background contrast ratios needed for
/// accessibility, in light and dark. That is why the app defines one colour
/// here rather than hard-coding colours on individual widgets.
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
