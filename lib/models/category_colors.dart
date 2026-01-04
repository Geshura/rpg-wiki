import 'package:flutter/material.dart';

class CategoryColors {
  static const Map<String, Color> worldCategoryColors = {
    'Pochodzenia': Color(0xFFFF6B4A),
    'Ścieżki Eksperckie': Color(0xFF4A9FFF),
    'Ścieżki Mistrzowskie': Color(0xFF9D4AFF),
    'Tradycje Magii': Color(0xFFFFB74A),
    'Artefakty': Color(0xFF4AFF9F),
    'Religia': Color(0xFFFF6B4A),
    'Rozwój profesji': Color(0xFF4A9FFF),
    'Sklep': Color(0xFF9D4AFF),
    'Zaklęcia': Color(0xFFFFB74A),
    'Bestiariusz': Color(0xFF4AFF9F),
    'Lokacje': Color(0xFFFF4A6B),
    'Przygody': Color(0xFF4AFF6B),
    'Zasady opcjonalne': Color(0xFF6B4AFF),
    'Artefakty i przedmioty': Color(0xFFFFB74A),
    'Frakcje i organizacje': Color(0xFF4AFF9F),
    'Bohaterowie niezależni': Color(0xFFFF9D4A),
    'Inne': Color(0xFF808080),
  };

  static Color getWorldCategoryColor(String categoryName) {
    return worldCategoryColors[categoryName] ?? const Color(0xFF808080);
  }
}
