import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/note.dart';
import '../models/note_category.dart';
import '../models/world_entry.dart';

class NotesBundle {
  NotesBundle({
    required this.notes,
    required this.categories,
    required this.worldEntries,
    required this.worldCategories,
    this.compendiumCategoryColors = const {},
    this.bookColors = const {},
  });

  final List<NoteItem> notes;
  final List<NoteCategory> categories;
  final List<WorldEntry> worldEntries;
  final List<String> worldCategories;
  final Map<String, int> compendiumCategoryColors; // String -> Color.value
  final Map<String, int> bookColors; // String -> Color.value

  Map<String, dynamic> toJson() => {
    'notes': notes.map((n) => n.toJson()).toList(),
    'categories': categories.map((c) => c.toJson()).toList(),
    'worldEntries': worldEntries.map((e) => e.toJson()).toList(),
    'worldCategories': worldCategories,
    'compendiumCategoryColors': compendiumCategoryColors,
    'bookColors': bookColors,
  };

  factory NotesBundle.fromJson(Map<String, dynamic> json) {
    final notesJson = json['notes'] as List<dynamic>? ?? [];
    final categoriesJson = json['categories'] as List<dynamic>? ?? [];
    final worldEntriesJson = json['worldEntries'] as List<dynamic>? ?? [];
    final worldCategoriesJson = json['worldCategories'] as List<dynamic>? ?? [];
    final compendiumColorsJson =
        json['compendiumCategoryColors'] as Map<String, dynamic>? ?? {};
    final bookColorsJson = json['bookColors'] as Map<String, dynamic>? ?? {};

    return NotesBundle(
      notes: notesJson
          .map((e) => NoteItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: categoriesJson
          .map((e) => NoteCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      worldEntries: worldEntriesJson
          .map((e) => WorldEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      worldCategories: worldCategoriesJson
          .map((e) => e.toString())
          .toSet()
          .toList(),
      compendiumCategoryColors: compendiumColorsJson.map(
        (k, v) => MapEntry(k, v as int),
      ),
      bookColors: bookColorsJson.map((k, v) => MapEntry(k, v as int)),
    );
  }
}

class StorageService {
  StorageService({this.fileName = 'notes_data.json'});

  final String fileName;

  Future<File> _resolveFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<NotesBundle> load() async {
    final file = await _resolveFile();
    if (!await file.exists()) {
      return NotesBundle(
        notes: [],
        categories: [],
        worldEntries: [],
        worldCategories: [],
        compendiumCategoryColors: {},
        bookColors: {},
      );
    }
    final raw = await file.readAsString();
    if (raw.isEmpty) {
      return NotesBundle(
        notes: [],
        categories: [],
        worldEntries: [],
        worldCategories: [],
        compendiumCategoryColors: {},
        bookColors: {},
      );
    }
    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    return NotesBundle.fromJson(jsonMap);
  }

  Future<void> save(NotesBundle bundle) async {
    final file = await _resolveFile();
    final encoded = json.encode(bundle.toJson());
    await file.writeAsString(encoded);
  }

  Future<File> exportBundle(NotesBundle bundle) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toString()
        .replaceAll(':', '-')
        .split('.')[0];
    final file = File('${dir.path}/note_rpg_export_$timestamp.json');
    await file.writeAsString(json.encode(bundle.toJson()));
    return file;
  }
}
