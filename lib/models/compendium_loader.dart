import 'package:flutter/services.dart';
import 'dart:convert';

class CompendiumEntry {
  final String name;
  final String source;
  final String book;
  final int page;
  final String description;
  final List<String>? traditions;
  final String? type;
  final int? level;
  final String? markdownPath;

  CompendiumEntry({
    required this.name,
    required this.source,
    required this.book,
    required this.page,
    this.description = '',
    this.traditions,
    this.type,
    this.level,
    this.markdownPath,
  });

  factory CompendiumEntry.fromJson(Map<String, dynamic> json) {
    final page = json['page'] ?? 0;
    final book = json['book'] ?? '';
    final traditionalValue = json['tradition'] ?? json['tradycja'];

    List<String>? traditions;
    if (traditionalValue is List) {
      traditions = traditionalValue
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (traditionalValue is String) {
      final trimmed = traditionalValue.trim();
      if (trimmed.isNotEmpty) traditions = [trimmed];
    }
    
    return CompendiumEntry(
      name: json['name'] ?? '',
      source: book,
      book: book,
      page: page is String ? int.tryParse(page) ?? 0 : page,
      description: (json['description'] ?? '').toString().replaceAll(
        RegExp(r"\s*\[cite:[^\]]*\]"),
        '',
      ),
      traditions: traditions,
      type: json['type'] ?? json['typ'],
      level: json['level'] is int
          ? json['level']
          : (json['level'] != null
                ? int.tryParse(json['level'].toString())
                : null),
      markdownPath: json['markdown_path'],
    );
  }
}

class CompendiumEntryWithCategory extends CompendiumEntry {
  final String categoryName;

  CompendiumEntryWithCategory({
    required super.name,
    required super.source,
    required super.book,
    required super.page,
    super.description,
    super.traditions,
    super.type,
    super.level,
    super.markdownPath,
    required this.categoryName,
  });
}

class CompendiumCategory {
  final String id;
  final String name;
  final String description;
  final List<CompendiumEntry> items;

  CompendiumCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
  });

  factory CompendiumCategory.fromJson(Map<String, dynamic> json) {
    var itemsList =
        (json['items'] as List?)
            ?.map((item) => CompendiumEntry.fromJson(item))
            .toList() ??
        [];

    return CompendiumCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      items: itemsList,
    );
  }
}

class ShadowDemonLordCompendium {
  final String title;
  final String description;
  final List<CompendiumCategory> categories;

  ShadowDemonLordCompendium({
    required this.title,
    required this.description,
    required this.categories,
  });

  factory ShadowDemonLordCompendium.fromJson(Map<String, dynamic> json) {
    var categoriesList =
        (json['categories'] as List?)
            ?.map((cat) => CompendiumCategory.fromJson(cat))
            .toList() ??
        [];

    return ShadowDemonLordCompendium(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      categories: categoriesList,
    );
  }

  static Future<ShadowDemonLordCompendium> loadFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/compendium_shadow_demon_lord.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return ShadowDemonLordCompendium.fromJson(jsonData);
    } catch (e) {
      rethrow;
    }
  }
}

extension CompendiumCategoryListExtension on List<CompendiumCategory> {
  List<CompendiumCategory> sortedByName() {
    final list = [...this];
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}
