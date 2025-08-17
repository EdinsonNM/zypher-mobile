import 'package:flutter/material.dart';

class ThemeColors {
  // Colores del tema claro
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightCardBackground = Colors.white;
  static const Color lightCardBorder = Color(0xFFE5E7EB);
  static const Color lightPrimaryText = Color(0xFF111827);
  static const Color lightSecondaryText = Color(0xFF4B5563);
  static const Color lightTertiaryText = Color(0xFF6B7280);
  static const Color lightDivider = Color(0xFFE5E7EB);

  // Colores del tema oscuro
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkCardBackground = Color(0xFF1F2937);
  static const Color darkCardBorder = Color(0xFF374151);
  static const Color darkPrimaryText = Colors.white;
  static const Color darkSecondaryText = Color(0xFFD1D5DB);
  static const Color darkTertiaryText = Color(0xFF9CA3AF);
  static const Color darkDivider = Color(0xFF374151);

  // Colores de acento (comunes para ambos temas)
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFF59E0B);
  static const Color accentGreen = Color(0xFF34D399);

  // Métodos para obtener colores según el tema
  static Color getBackground(ThemeData theme) {
    return theme.brightness == Brightness.light ? lightBackground : darkBackground;
  }

  static Color getCardBackground(ThemeData theme) {
    return theme.brightness == Brightness.light ? lightCardBackground : darkCardBackground;
  }

  static Color getCardBorder(ThemeData theme) {
    return theme.brightness == Brightness.light ? lightCardBorder : darkCardBorder;
  }

  static Color getPrimaryText(ThemeData theme) {
    return theme.brightness == Brightness.light ? lightPrimaryText : darkPrimaryText;
  }

  static Color getSecondaryText(ThemeData theme) {
    return theme.brightness == Brightness.light ? lightSecondaryText : darkSecondaryText;
  }

  static Color getTertiaryText(ThemeData theme) {
    return theme.brightness == Brightness.light ? lightTertiaryText : darkTertiaryText;
  }

  static Color getDivider(ThemeData theme) {
    return theme.brightness == Brightness.light ? lightDivider : darkDivider;
  }

  // Colores específicos para elementos comunes
  static Color getSurfaceColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? Colors.white : const Color(0xFF1F2937);
  }

  static Color getErrorColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? const Color(0xFFDC2626) : const Color(0xFFEF4444);
  }

  static Color getSuccessColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399);
  }

  static Color getWarningColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? const Color(0xFFD97706) : const Color(0xFFF59E0B);
  }

  static Color getInfoColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? const Color(0xFF2563EB) : const Color(0xFF60A5FA);
  }
}


