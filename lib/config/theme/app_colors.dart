import 'package:flutter/material.dart';

/// Al Mahabbah design palette.
abstract final class AppColors {
  // 🔹 Brand reds
  static const Color mahabbahRed = Color(0xFF8E1616);
  static const Color actionRed = Color(0xFFB02828);
  static const Color maroon = Color(0xFF6C0909);
  static const Color rose = Color(0xFFF8D3D3);
  static const Color blush = Color(0xFFFFEDED);

  // 🔹 Neutrals (text, borders, backgrounds)
  static const Color ink = Color(0xFF252B42);
  static const Color charcoal = Color(0xFF2D2F2F);
  static const Color slate = Color(0xFF5C6070);
  static const Color mist = Color(0xFFA3A7B4);
  static const Color line = Color(0xFFE6E7EC);
  static const Color surface = Color(0xFFF7F7F9);
  static const Color white = Color(0xFFFFFFFF);

  // 🔹 Gold accent
  static const Color gold = Color(0xFFF3DC93);
  static const Color goldText = Color(0xFF6B520A);
  static const Color goldDeep = Color(0xFF8A6A0C);

  /// Pale gold card background — used in the page designs, not in colors.xml.
  static const Color goldSoft = Color(0xFFFBF6E4);

  /// Input placeholder text — used in the page designs, not in colors.xml.
  static const Color placeholder = Color(0xFF6E7385);

  /// Dashed line between chat messages — used in the page designs, not in
  /// colors.xml.
  static const Color separator = Color(0xFFCDD0D9);

  // 🔹 Status
  static const Color success = Color(0xFF1E7F4F);
  static const Color successBg = Color(0xFFE3F3EA);
  static const Color warning = Color(0xFFB45309);
  static const Color warningBg = Color(0xFFFDF0E1);
  static const Color error = Color(0xFFD92D20);

  /// A form's error box (background, border) — used in the page designs,
  /// not in colors.xml.
  static const Color errorBg = Color(0xFFFDECEA);
  static const Color errorBorder = Color(0xFFF5C2BD);
  static const Color info = Color(0xFF2557D6);

  /// Light background for [info] — used in the page designs, not in
  /// colors.xml.
  static const Color infoBg = Color(0xFFE8EEFC);

  /// A row's top line inside a card — used in the page designs, not in
  /// colors.xml.
  static const Color hairline = Color(0xFFF0F0F3);

  /// A card's title strip (fee statement) — used in the page designs, not
  /// in colors.xml.
  static const Color paleSurface = Color(0xFFFAFAFB);

  /// A ticked installment's background — used in the page designs, not in
  /// colors.xml.
  static const Color blushPale = Color(0xFFFFF7F7);

  /// A password rule not met yet — used in the page designs, not in
  /// colors.xml.
  static const Color unmet = Color(0xFFC9CCD5);

  /// A bottom sheet's drag handle, and the dim behind it — used in the page
  /// designs, not in colors.xml.
  static const Color handle = Color(0xFFD5D8E0);
  static const Color scrim = Color(0x7A141620);

  /// An installment under settlement — used in the page designs, not in
  /// colors.xml.
  static const Color settlement = Color(0xFF5B3CC4);
  static const Color settlementBg = Color(0xFFECE8FB);

  // 🔹 The school's grade scale (result colors), by share of the mark
  static const Color gradeExceeds = Color(0xFF0B5ED7); // 85 – 100
  static const Color gradeMeets = Color(0xFF1E7E34); // 65 – 85
  static const Color gradePartiallyMeets = Color(0xFFEBCE2D); // 50 – 65
  static const Color gradeBelow = Color(0xFFB91C1C); // below 50

  // 🔹 Dark mode (not in the design palette)
  static const Color darkBackground = Color(0xFF121417);
}
