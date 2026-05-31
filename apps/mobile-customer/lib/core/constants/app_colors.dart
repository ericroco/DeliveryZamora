import 'package:flutter/material.dart';

abstract final class AppColors {
  // Earthy Premium palette
  static const Color bg = Color(0xFFFAF7F2);
  static const Color card = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFB85C3F); // terracota
  static const Color accent = Color(0xFF2D5016);  // dark green
  static const Color text = Color(0xFF1F1F1F);
  static const Color muted = Color(0xFF6B6B6B);
  static const Color cream = Color(0xFFF5EDE4);

  // Caseros special
  static const Color caseroBg = Color(0xFFFDF2EE);
  static const Color caseroText = Color(0xFF8B3A1F);
  static const Color caseroBorder = Color(0xFFE8C5B5);

  // Borders
  static const Color cardBorder = Color(0xFFEDE6DC);
  static const Color navBorder = Color(0xFFE8E0D6);
  static const Color pillBorder = Color(0xFFD9CFC4);
  static const Color inputBorder = Color(0xFFE8E0D6);

  // Category pills (non-casero)
  static const Color pillBg = Color(0xFFF5EDE4);     // cream
  static const Color pillText = Color(0xFF2D5016);    // accent

  // Casero tag (inside store card)
  static const Color caseroTagBg = Color(0xFFFDF2EE);
  static const Color defaultTagBg = Color(0xFFE8F5E9);
  static const Color defaultTagText = Color(0xFF2D5016);
}
