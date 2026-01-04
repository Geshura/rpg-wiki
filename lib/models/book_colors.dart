import 'package:flutter/material.dart';

class BookColors {
  static const Map<String, Color> bookColorMap = {
    'Podręcznik Główny': Color(0xFF6366F1),
    'Suplement Władcy Demonów': Color(0xFFF43F5E),
    'Straszliwe Piękno': Color(0xFF8B5CF6),
    'Głód w Pustce': Color(0xFFD946EF),
    'Niepewna Wiara': Color(0xFF0EA5E9),
    'Rozkoszna Agonia': Color(0xFFF59E0B),
    'Grobowce Pustkowia': Color(0xFF10B981),
    'Chwalebna Śmierć': Color(0xFFEF4444),
  };

  static Color getBookColor(String bookName) {
    return bookColorMap[bookName] ?? const Color(0xFF6B7280);
  }

  static Map<String, Color> getBookColors() => bookColorMap;

  static void setBookColor(String bookName, Color color) {
    // Ta metoda będzie wykorzystywana gdy dodamy persist storage
    // Na razie traktujemy jako statyczne
  }
}
