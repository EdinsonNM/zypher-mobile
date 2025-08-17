import 'package:flutter/material.dart';

class DashboardColors {
  // Colores principales del tema oscuro
  static const Color mainBackground = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF1F2937);
  static const Color cardBorder = Color(0xFF374151);
  
  // Colores de texto
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xFFD1D5DB);
  static const Color tertiaryText = Color(0xFF6B7280);
  
  // Colores de acento
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFF59E0B);
  static const Color accentGreen = Color(0xFF34D399);
  
  // Colores de separadores y líneas
  static const Color dividerColor = Color(0xFF374151);
  static const Color gridLineColor = Color(0xFF6B7280);
  
  // Colores de las barras del gráfico
  static const Color barBlue = Color(0xFF3B82F6);
  static const Color barRed = Color(0xFFEF4444);

  // Métodos para colores responsive al tema
  static Color getMainBackground(ThemeData theme) {
    return theme.brightness == Brightness.light 
        ? Colors.grey[50]! 
        : mainBackground;
  }

  static Color getCardBackground(ThemeData theme) {
    return theme.brightness == Brightness.light 
        ? Colors.white 
        : cardBackground;
  }

  static Color getCardBorder(ThemeData theme) {
    return theme.brightness == Brightness.light 
        ? Colors.grey[300]! 
        : cardBorder;
  }

  static Color getPrimaryText(ThemeData theme) {
    return theme.brightness == Brightness.light 
        ? Colors.black87 
        : primaryText;
  }

  static Color getSecondaryText(ThemeData theme) {
    return theme.brightness == Brightness.light 
        ? Colors.black54 
        : secondaryText;
  }

  static Color getTertiaryText(ThemeData theme) {
    return theme.brightness == Brightness.light 
        ? Colors.black45 
        : tertiaryText;
  }

  static Color getDividerColor(ThemeData theme) {
    return theme.brightness == Brightness.light 
        ? Colors.grey[300]! 
        : dividerColor;
  }

  static Color getGridLineColor(ThemeData theme) {
    return theme.brightness == Brightness.light 
        ? Colors.grey[400]! 
        : gridLineColor;
  }
}
