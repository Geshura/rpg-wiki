import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../models/note_category.dart';
import '../services/storage_service.dart';
import '../models/world_entry.dart';

class NoteState extends ChangeNotifier {
  NoteState({StorageService? storage}) : _storage = storage ?? StorageService();

  final StorageService _storage;
  final _uuid = const Uuid();

  bool isLoading = false;
  List<NoteItem> _notes = [];
  List<NoteCategory> _categories = [];
  List<WorldEntry> _worldEntries = [];
  List<String> _worldCategories = [];
  Map<String, Color> _compendiumCategoryColors = {};
  Map<String, Color> _bookColors = {};

  List<NoteItem> get notes => List.unmodifiable(_notes);
  List<NoteCategory> get categories => List.unmodifiable(_categories);
  List<WorldEntry> get worldEntries => List.unmodifiable(_worldEntries);
  List<String> get worldCategories => List.unmodifiable(_worldCategories);
  Map<String, Color> get compendiumCategoryColors =>
      Map.unmodifiable(_compendiumCategoryColors);
  Map<String, Color> get bookColors => Map.unmodifiable(_bookColors);

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    final bundle = await _storage.load();
    _notes = bundle.notes;
    if (bundle.categories.isEmpty) {
      _categories = _seedCategories();
    } else {
      _categories = _migrateCategories(bundle.categories);
    }
    _worldEntries = bundle.worldEntries;
    _worldCategories = _migrateWorldCategories(bundle.worldCategories);
    if (_worldEntries.isEmpty) {
      _worldEntries = _seedWorldEntries();
    }

    // Load compendium category colors
    if (bundle.compendiumCategoryColors.isEmpty) {
      _compendiumCategoryColors = _seedCompendiumCategoryColors();
    } else {
      _compendiumCategoryColors = bundle.compendiumCategoryColors.map(
        (k, v) => MapEntry(k, Color(v)),
      );
    }

    // Load book colors
    if (bundle.bookColors.isEmpty) {
      _bookColors = _seedBookColors();
    } else {
      _bookColors = bundle.bookColors.map((k, v) => MapEntry(k, Color(v)));
    }

    await _persist();
    isLoading = false;
    notifyListeners();
  }

  List<NoteCategory> _migrateCategories(List<NoteCategory> existing) {
    var changed = false;

    final migrated = existing.map((c) {
      final lower = c.name.trim().toLowerCase();
      if (lower == 'session') {
        changed = true;
        return NoteCategory(id: c.id, name: 'Sesja', color: c.color);
      }
      return c;
    }).toList();

    bool hasName(String name) =>
        migrated.any((c) => c.name.trim().toLowerCase() == name.toLowerCase());

    void ensureCategory({required String name, required Color color}) {
      if (hasName(name)) return;
      migrated.add(NoteCategory(id: _uuid.v4(), name: name, color: color));
      changed = true;
    }

    ensureCategory(name: 'Sesja', color: Colors.blueGrey);
    ensureCategory(name: 'NPC', color: Colors.teal);
    ensureCategory(name: 'Quest', color: Colors.indigo);
    ensureCategory(name: 'Towarzysze', color: Colors.orange);
    ensureCategory(name: 'Moja postać', color: Colors.cyan);

    if (changed) {
      migrated.sort((a, b) => a.name.compareTo(b.name));
    }

    return migrated;
  }

  List<NoteCategory> _seedCategories() {
    return [
      NoteCategory(id: _uuid.v4(), name: 'Sesja', color: Colors.blueGrey),
      NoteCategory(id: _uuid.v4(), name: 'NPC', color: Colors.teal),
      NoteCategory(id: _uuid.v4(), name: 'Quest', color: Colors.indigo),
      NoteCategory(id: _uuid.v4(), name: 'Towarzysze', color: Colors.orange),
      NoteCategory(id: _uuid.v4(), name: 'Moja postać', color: Colors.cyan),
    ];
  }

  List<String> _migrateWorldCategories(List<String> existing) {
    final seeds = _seedWorldCategories();
    final normalized = <String>{};

    for (final c in existing) {
      final trimmed = c.trim();
      if (trimmed.isNotEmpty) normalized.add(trimmed);
    }

    normalized.addAll(seeds);

    final list = normalized.toList();
    list.sort();
    return list;
  }

  List<String> _seedWorldCategories() => [
    'Religia',
    'Rozwój profesji',
    'Sklep',
    'Zaklęcia',
    'Bestiariusz',
    'Lokacje',
    'Przygody',
    'Zasady opcjonalne',
    'Artefakty i przedmioty',
    'Frakcje i organizacje',
    'Bohaterowie niezależni',
    'Inne',
  ];

  List<WorldEntry> _seedWorldEntries() {
    final now = DateTime.now();
    WorldEntry entry(String title, String category, String desc) => WorldEntry(
      id: _uuid.v4(),
      title: title,
      category: category,
      description: desc,
      createdAt: now,
      updatedAt: now,
    );

    return [
      entry(
        'Religia',
        'Religia',
        'Główni bogowie, demony i kulty. Dodaj rytuały, święta i tabu.',
      ),
      entry(
        'Drogi rozwoju',
        'Rozwój profesji',
        'Ścieżki novice/ekspert/mistrz, wymagania i kluczowe zdolności.',
      ),
      entry(
        'Sklep / wyposażenie',
        'Sklep',
        'Ceny, dostępność, ograniczenia jakości; notuj lokalne modyfikatory.',
      ),
      entry(
        'Zaklęcia',
        'Zaklęcia',
        'Listy szkół i kluczowe czary do szybkiego wglądu.',
      ),
      entry(
        'Bestiariusz',
        'Bestiariusz',
        'Szybkie statystyki potworów, ataki specjalne i odporności.',
      ),
      entry(
        'Lokacje',
        'Lokacje',
        'Miasta, ruiny, punkty zaczepienia — klimat, zagrożenia, haki.',
      ),
      entry(
        'Zasady opcjonalne',
        'Zasady opcjonalne',
        'House rules, modyfikacje obrażeń, zmęczenie, choroby.',
      ),
      entry(
        'Artefakty',
        'Artefakty i przedmioty',
        'Unikalne przedmioty, przeklęte relikty, koszty i haczyki fabularne.',
      ),
      entry(
        'Frakcje',
        'Frakcje i organizacje',
        'Struktura, cele, zasoby frakcji; sojusze i wrogości.',
      ),
      entry(
        'BN do sesji',
        'Bohaterowie niezależni',
        'Nazwy, motywacje, sekrety, głosy/maniery, relacje.',
      ),
      entry(
        'Przygody / haki',
        'Przygody',
        'Zalążki scenariuszy, komplikacje, nagrody, zegary zagrożeń.',
      ),
      entry('Inne', 'Inne', 'Luźne notatki, których nie ma gdzie indziej.'),
    ];
  }

  Future<void> addOrUpdateNote(NoteItem note) async {
    note.updatedAt = DateTime.now();
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    _sortNotes();
    await _persist();
    notifyListeners();
  }

  NoteItem createBlankNote() {
    final now = DateTime.now();
    return NoteItem(
      id: _uuid.v4(),
      title: '',
      body: '',
      categoryId: _categories.isEmpty ? null : _categories.first.id,
      createdAt: now,
      updatedAt: now,
      importance: NoteImportance.normal,
    );
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> addCategory(NoteCategory category) async {
    _categories.add(category);
    await _persist();
    notifyListeners();
  }

  Future<void> updateCategory(NoteCategory category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      _categories[index] = category;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    _notes = _notes
        .map((n) => n..categoryId = n.categoryId == id ? null : n.categoryId)
        .toList();
    await _persist();
    notifyListeners();
  }

  NoteCategory? categoryFor(String? id) {
    if (id == null) return null;
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => NoteCategory(id: '', name: 'Brak', color: Colors.grey),
    );
  }

  // --- World entries ---

  WorldEntry createBlankWorldEntry() {
    final now = DateTime.now();
    return WorldEntry(
      id: _uuid.v4(),
      title: '',
      category: _worldCategories.isEmpty ? 'Inne' : _worldCategories.first,
      description: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> addOrUpdateWorldEntry(WorldEntry entry) async {
    entry.updatedAt = DateTime.now();
    final idx = _worldEntries.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      _worldEntries[idx] = entry;
    } else {
      _worldEntries.add(entry);
    }
    _worldEntries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteWorldEntry(String id) async {
    _worldEntries.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> addWorldCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_worldCategories.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }
    _worldCategories.add(trimmed);
    _worldCategories.sort();
    await _persist();
    notifyListeners();
  }

  Future<void> updateWorldCategory(String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.toLowerCase() == oldName.toLowerCase()) return;

    final existingIdx = _worldCategories.indexWhere(
      (c) => c.toLowerCase() == oldName.toLowerCase(),
    );
    if (existingIdx == -1) return;

    if (_worldCategories.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }

    _worldCategories[existingIdx] = trimmed;
    _worldCategories.sort();

    _worldEntries = _worldEntries
        .map((e) => e.category.toLowerCase() == oldName.toLowerCase()
            ? e.copyWith(category: trimmed)
            : e)
        .toList();

    await _persist();
    notifyListeners();
  }

  Future<void> removeWorldCategory(String name) async {
    final target = name.trim();
    if (target.isEmpty) return;

    _worldCategories.removeWhere(
      (c) => c.toLowerCase() == target.toLowerCase(),
    );

    // Ensure fallback category exists
    if (!_worldCategories.any((c) => c.toLowerCase() == 'inne')) {
      _worldCategories.add('Inne');
    }
    _worldCategories.sort();

    _worldEntries = _worldEntries
        .map((e) => e.category.toLowerCase() == target.toLowerCase()
            ? e.copyWith(category: 'Inne')
            : e)
        .toList();

    await _persist();
    notifyListeners();
  }

  Future<File> exportToFile() async {
    final bundle = NotesBundle(
      notes: _notes,
      categories: _categories,
      worldEntries: _worldEntries,
      worldCategories: _worldCategories,
      compendiumCategoryColors: _compendiumCategoryColors.map(
        // ignore: deprecated_member_use
        (k, v) => MapEntry(k, v.value),
      ),
      bookColors: _bookColors.map(
        // ignore: deprecated_member_use
        (k, v) => MapEntry(k, v.value),
      ),
    );
    return _storage.exportBundle(bundle);
  }

  Future<void> importFromJsonString(String jsonString) async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final bundle = NotesBundle.fromJson(decoded);
    _notes = bundle.notes;
    _categories = bundle.categories.isEmpty
        ? _seedCategories()
        : bundle.categories;
    _worldEntries = bundle.worldEntries;
    _worldCategories = _migrateWorldCategories(bundle.worldCategories);
    _sortNotes();
    await _persist();
    notifyListeners();
  }

  void _sortNotes() {
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _persist() async {
    await _storage.save(
      NotesBundle(
        notes: _notes,
        categories: _categories,
        worldEntries: _worldEntries,
        worldCategories: _worldCategories,
        compendiumCategoryColors: _compendiumCategoryColors.map(
          // ignore: deprecated_member_use
          (k, v) => MapEntry(k, v.value),
        ),
        bookColors: _bookColors.map(
          // ignore: deprecated_member_use
          (k, v) => MapEntry(k, v.value),
        ),
      ),
    );
  }

  Map<String, Color> _seedCompendiumCategoryColors() => {
    'Pochodzenia': const Color(0xFFFF6B4A),
    'Ścieżki Eksperckie': const Color(0xFF4A9FFF),
    'Ścieżki Mistrzowskie': const Color(0xFF9D4AFF),
    'Tradycje Magii': const Color(0xFFFFB74A),
    'Artefakty': const Color(0xFF4AFF9F),
    'Religia': const Color(0xFFFF6B4A),
    'Rozwój profesji': const Color(0xFF4A9FFF),
    'Sklep': const Color(0xFF9D4AFF),
    'Zaklęcia': const Color(0xFFFFB74A),
    'Bestiariusz': const Color(0xFF4AFF9F),
    'Lokacje': const Color(0xFFFF4A6B),
    'Przygody': const Color(0xFF4AFF6B),
    'Zasady opcjonalne': const Color(0xFF6B4AFF),
    'Artefakty i przedmioty': const Color(0xFFFFB74A),
    'Frakcje i organizacje': const Color(0xFF4AFF9F),
    'Bohaterowie niezależni': const Color(0xFFFF9D4A),
    'Inne': const Color(0xFF808080),
  };

  Map<String, Color> _seedBookColors() => {
    'Podręcznik Główny': const Color(0xFF6366F1),
    'Suplement Władcy Demonów': const Color(0xFFF43F5E),
    'Straszliwe Piękno': const Color(0xFF8B5CF6),
    'Głód w Pustce': const Color(0xFFD946EF),
    'Niepewna Wiara': const Color(0xFF0EA5E9),
    'Rozkoszna Agonia': const Color(0xFFF59E0B),
    'Grobowce Pustkowia': const Color(0xFF10B981),
    'Chwalebna Śmierć': const Color(0xFFEF4444),
  };

  Color getCompendiumCategoryColor(String categoryName) {
    return _compendiumCategoryColors[categoryName] ?? const Color(0xFF808080);
  }

  Color getBookColor(String bookName) {
    return _bookColors[bookName] ?? const Color(0xFF6B7280);
  }

  Future<void> setCompendiumCategoryColor(
    String categoryName,
    Color color,
  ) async {
    _compendiumCategoryColors[categoryName] = color;
    await _persist();
    notifyListeners();
  }

  Future<void> setBookColor(String bookName, Color color) async {
    _bookColors[bookName] = color;
    await _persist();
    notifyListeners();
  }
}
