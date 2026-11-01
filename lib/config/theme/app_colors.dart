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
  static const Color info = Color(0xFF2557D6);

  // 🔹 Dark mode (not in the design palette)
  static const Color darkBackground = Color(0xFF121417);
}
