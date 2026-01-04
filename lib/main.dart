import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import 'models/note.dart';
import 'models/note_category.dart';
import 'models/world_entry.dart';
import 'models/compendium_loader.dart';
import 'pages/world_entry_details_page.dart';
import 'pages/note_details_page.dart';
import 'state/note_state.dart';

// Utility: convert strings like "WODA" or "MAGIA BURZY" to Title Case -> "Woda", "Magia Burzy"
String titleCase(String s) {
  if (s.trim().isEmpty) return s;
  return s
      .split(RegExp(r"\s+"))
      .map((w) {
        final lower = w.toLowerCase();
        return lower.length > 1
            ? '${lower[0].toUpperCase()}${lower.substring(1)}'
            : lower.toUpperCase();
      })
      .join(' ');
}

enum _MenuSection {
  notes,
  shadowDemonLord,
  warhammer4ed,
  fallout2d20,
  cyberpunkRed,
  neuroshima15ed,
  neuroshima5ed,
  cthulhu7ed,
  deltaGreen,
  archive,
  settings,
}

class ThemeState extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NoteRpgApp());
}

class NoteRpgApp extends StatelessWidget {
  const NoteRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF6366F1);

    final lightColorScheme = ColorScheme.light(
      primary: const Color(0xFF5B21B6),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEDE9FE),
      onPrimaryContainer: const Color(0xFF3B0764),
      secondary: const Color(0xFF7C3AED),
      onSecondary: Colors.white,
      error: const Color(0xFFDC2626),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF1F2937),
      surfaceContainerHighest: const Color(0xFFF3F4F6),
      outline: const Color(0xFFD1D5DB),
      shadow: Colors.black26,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFF374151)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w800,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w700,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: Color(0xFF374151),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Color(0xFF1F2937), height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFF1F2937), height: 1.5),
        bodySmall: TextStyle(color: Color(0xFF6B7280), height: 1.4),
        labelLarge: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: Color(0xFF374151),
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF374151)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
        labelStyle: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF5B21B6),
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B21B6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF5B21B6),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF5B21B6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      dividerColor: const Color(0xFFE5E7EB),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),
    );

    final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF0f1115),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0f1115),
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      cardColor: const Color(0xFF1b1f27),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151922),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteState()..init()),
        ChangeNotifierProvider(create: (_) => ThemeState()),
      ],
      child: Consumer<ThemeState>(
        builder: (context, themeState, _) {
          return MaterialApp(
            title: 'NoteRPG',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const NoteHomePage(),
          );
        },
      ),
    );
  }
}

class NoteHomePage extends StatefulWidget {
  const NoteHomePage({super.key});

  @override
  State<NoteHomePage> createState() => _NoteHomePageState();
}

class _NoteHomePageState extends State<NoteHomePage> {
  String _query = '';
  String? _selectedCategoryId;
  _MenuSection _section = _MenuSection.notes;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NoteState>();
    final notes = _filteredNotes(state);
    final sectionTitle = switch (_section) {
      _MenuSection.notes => 'NoteRPG',
      _MenuSection.shadowDemonLord => 'Cień Władcy Demonów',
      _MenuSection.warhammer4ed => 'Warhammer 4ed',
      _MenuSection.fallout2d20 => 'Fallout (2d20)',
      _MenuSection.cyberpunkRed => 'Cyberpunk RED',
      _MenuSection.neuroshima15ed => 'Neuroshima 1.5ed',
      _MenuSection.neuroshima5ed => 'Neuroshima 5ed',
      _MenuSection.cthulhu7ed => 'Zew Cthulhu 7ed',
      _MenuSection.deltaGreen => 'Delta Green',
      _MenuSection.archive => 'Archiwum',
      _MenuSection.settings => 'Ustawienia',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(sectionTitle),
        actions: const [],
      ),
      drawer: _AppMenu(
        current: _section,
        onSelected: (section) {
          Navigator.of(context).maybePop();
          setState(() => _section = section);
        },
      ),
      floatingActionButton: _section == _MenuSection.notes
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Nowa notatka'),
              onPressed: () {
                final note = state.createBlankNote();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteEditorPage(note: note, isNew: true),
                  ),
                );
              },
            )
          : null,
      body: switch (_section) {
        _MenuSection.notes => _NotesSection(
          state: state,
          notes: notes,
          query: _query,
          onQueryChanged: (v) => setState(() => _query = v),
          selectedCategoryId: _selectedCategoryId,
          onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
        ),
        _MenuSection.shadowDemonLord => _ShadowDemonLordSection(state: state),
        _MenuSection.warhammer4ed => const _PlaceholderSection(
          icon: Icons.auto_stories,
          title: 'Warhammer 4ed',
          message: 'Kompendium w przygotowaniu.',
        ),
        _MenuSection.fallout2d20 => const _PlaceholderSection(
          icon: Icons.auto_stories,
          title: 'Fallout (2d20)',
          message: 'Kompendium w przygotowaniu.',
        ),
        _MenuSection.cyberpunkRed => const _PlaceholderSection(
          icon: Icons.auto_stories,
          title: 'Cyberpunk RED',
          message: 'Kompendium w przygotowaniu.',
        ),
        _MenuSection.neuroshima15ed => const _PlaceholderSection(
          icon: Icons.auto_stories,
          title: 'Neuroshima 1.5ed',
          message: 'Kompendium w przygotowaniu.',
        ),
        _MenuSection.neuroshima5ed => const _PlaceholderSection(
          icon: Icons.auto_stories,
          title: 'Neuroshima 5ed',
          message: 'Kompendium w przygotowaniu.',
        ),
        _MenuSection.cthulhu7ed => const _PlaceholderSection(
          icon: Icons.auto_stories,
          title: 'Zew Cthulhu 7ed',
          message: 'Kompendium w przygotowaniu.',
        ),
        _MenuSection.deltaGreen => const _PlaceholderSection(
          icon: Icons.auto_stories,
          title: 'Delta Green',
          message: 'Kompendium w przygotowaniu.',
        ),
        _MenuSection.archive => const _PlaceholderSection(
          icon: Icons.archive_outlined,
          title: 'Archiwum',
          message: 'Wkrótce przechowywanie zakończonych notatek.',
        ),
        _MenuSection.settings => _SettingsSection(
          onImport: () => _importNotes(state),
          onExport: () => _exportNotes(state),
        ),
      },
    );
  }

  List<NoteItem> _filteredNotes(NoteState state) {
    final lower = _query.toLowerCase();
    return state.notes.where((note) {
      final matchesQuery =
          _query.isEmpty ||
          note.title.toLowerCase().contains(lower) ||
          note.body.toLowerCase().contains(lower) ||
          (note.transcript ?? '').toLowerCase().contains(lower);
      final matchesCategory =
          _selectedCategoryId == null || note.categoryId == _selectedCategoryId;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<void> _importNotes(NoteState state) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return;
    try {
      final path = result.files.single.path;
      if (path == null) return;
      final file = File(path);
      final content = await file.readAsString();
      await state.importFromJsonString(content);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Zaimportowano notatki.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import nieudany: $e')));
    }
  }

  Future<void> _exportNotes(NoteState state) async {
    try {
      final file = await state.exportToFile();
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Eksport notatek NoteRPG');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export nieudany: $e')));
    }
  }

}

class _AppMenu extends StatelessWidget {
  const _AppMenu({required this.current, required this.onSelected});

  final _MenuSection current;
  final ValueChanged<_MenuSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0f1115)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _MenuTile(
              icon: Icons.note_alt_outlined,
              title: 'Notatki',
              section: _MenuSection.notes,
              current: current,
              onSelected: onSelected,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Systemy',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _SystemTile(
              title: 'Cień Władcy Demonów',
              icon: Icons.whatshot,
              section: _MenuSection.shadowDemonLord,
              current: current,
              onSelected: onSelected,
            ),
            _SystemTile(
              title: 'Cyberpunk RED',
              icon: Icons.cable,
              section: _MenuSection.cyberpunkRed,
              current: current,
              onSelected: onSelected,
            ),
            _SystemTile(
              title: 'Delta Green',
              icon: Icons.fingerprint,
              section: _MenuSection.deltaGreen,
              current: current,
              onSelected: onSelected,
            ),
            _SystemTile(
              title: 'Fallout (2d20)',
              icon: Icons.signpost,
              section: _MenuSection.fallout2d20,
              current: current,
              onSelected: onSelected,
            ),
            _SystemTile(
              title: 'Neuroshima 1.5ed',
              icon: Icons.warning,
              section: _MenuSection.neuroshima15ed,
              current: current,
              onSelected: onSelected,
            ),
            _SystemTile(
              title: 'Neuroshima 5ed',
              icon: Icons.warning_amber,
              section: _MenuSection.neuroshima5ed,
              current: current,
              onSelected: onSelected,
            ),
            _SystemTile(
              title: 'Warhammer 4ed',
              icon: Icons.security,
              section: _MenuSection.warhammer4ed,
              current: current,
              onSelected: onSelected,
            ),
            _SystemTile(
              title: 'Zew Cthulhu 7ed',
              icon: Icons.library_books,
              section: _MenuSection.cthulhu7ed,
              current: current,
              onSelected: onSelected,
            ),
            const Divider(),
            _MenuTile(
              icon: Icons.archive_outlined,
              title: 'Archiwum',
              section: _MenuSection.archive,
              current: current,
              onSelected: onSelected,
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              title: 'Ustawienia',
              section: _MenuSection.settings,
              current: current,
              onSelected: onSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemTile extends StatelessWidget {
  const _SystemTile({
    required this.title,
    required this.icon,
    this.section,
    this.current,
    this.onSelected,
  });

  final String title;
  final IconData icon;
  final _MenuSection? section;
  final _MenuSection? current;
  final ValueChanged<_MenuSection>? onSelected;

  @override
  Widget build(BuildContext context) {
    final bool selected = section != null && current == section;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selected,
      onTap: () {
        Navigator.of(context).maybePop();
        if (section != null && onSelected != null) {
          onSelected!(section!);
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Wybrano system: $title')));
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.section,
    required this.current,
    required this.onSelected,
  });

  final IconData icon;
  final String title;
  final _MenuSection section;
  final _MenuSection current;
  final ValueChanged<_MenuSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: section == current,
      onTap: () => onSelected(section),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({
    required this.state,
    required this.notes,
    required this.query,
    required this.onQueryChanged,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final NoteState state;
  final List<NoteItem> notes;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Szukaj w notatkach...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: 12),
          _CategoryFilter(
            categories: state.categories,
            selectedId: selectedCategoryId,
            onSelected: onCategorySelected,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : notes.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final category = state.categoryFor(note.categoryId);
                      return _NoteCard(
                        note: note,
                        category: category,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NoteDetailsPage(
                                note: note,
                                category: category,
                                onEdit: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => NoteEditorPage(
                                        note: note,
                                        isNew: false,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () => state.deleteNote(note.id),
                              ),
                            ),
                          );
                        },
                        onDelete: () => state.deleteNote(note.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.onImport,
    required this.onExport,
  });

  final VoidCallback onImport;
  final VoidCallback onExport;

  static final _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    const Color(0xFFFF6B4A),
    const Color(0xFF4A9FFF),
    const Color(0xFF9D4AFF),
    const Color(0xFFFFB74A),
    const Color(0xFF4AFF9F),
    const Color(0xFFFF4A6B),
    const Color(0xFF4AFF6B),
    const Color(0xFF6B4AFF),
    const Color(0xFFFF9D4A),
    const Color(0xFF6366F1),
    const Color(0xFFF43F5E),
    const Color(0xFF8B5CF6),
    const Color(0xFFD946EF),
    const Color(0xFF0EA5E9),
    const Color(0xFFF59E0B),
    const Color(0xFF10B981),
    const Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeState>();
    final isDark = themeState.isDarkMode;
    final noteState = context.watch<NoteState>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGroup(
          'Ogólne',
          [
            Card(
              child: ListTile(
                leading: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Motyw',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(isDark ? 'Ciemny' : 'Jasny'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) => themeState.setTheme(value),
                ),
              ),
            ),
            _buildImportExportSection(context),
          ],
        ),

        _buildGroup(
          'Notatki',
          [
            _buildNoteCategoriesSection(context, noteState),
          ],
        ),

        _buildGroup(
          'Cień Władcy Demonów — Kompendium',
          [
            _buildColorSection(
              context,
              'Kolory kategorii kompendium',
              Icons.palette_outlined,
              noteState.compendiumCategoryColors,
              (name, color) =>
                  noteState.setCompendiumCategoryColor(name, color),
            ),
            _buildColorSection(
              context,
              'Kolory podręczników',
              Icons.book_outlined,
              noteState.bookColors,
              (name, color) => noteState.setBookColor(name, color),
            ),
          ],
        ),

        _buildGroup(
          'Cień Władcy Demonów — Notatki',
          [
            _buildCategoryManagementSection(context, noteState),
          ],
        ),

        _buildGroup(
          'Informacje',
          [
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'O aplikacji',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('NoteRPG v1.0.0'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroup(String title, List<Widget> items) {
    final children = <Widget>[_buildSectionHeader(title)];
    for (var i = 0; i < items.length; i++) {
      children.add(items[i]);
      if (i != items.length - 1) {
        children.add(const SizedBox(height: 12));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildNoteCategoriesSection(
    BuildContext context,
    NoteState noteState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kategorie notatek',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NoteCategoriesSection(noteState: noteState),
          ],
        ),
      ),
    );
  }

  Widget _buildImportExportSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.import_export,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Import / Export',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Import JSON'),
                ),
                OutlinedButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.upload_outlined),
                  label: const Text('Eksport JSON'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(
    BuildContext context,
    String title,
    IconData icon,
    Map<String, Color> items,
    Function(String, Color) onColorChanged,
  ) {
    final sortedKeys = items.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sortedKeys.map((name) {
              final color = items[name]!;
              return _ColorPickerItem(
                name: name,
                color: color,
                availableColors: _availableColors,
                onColorChanged: (c) => onColorChanged(name, c),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryManagementSection(
    BuildContext context,
    NoteState noteState,
  ) {
    final sortedCategories = noteState.worldCategories.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Kategorie świata',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Dodaj kategorię',
                  onPressed: () => _showAddCategoryDialog(context, noteState),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sortedCategories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Brak kategorii. Dodaj pierwszą używając przycisku +',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...sortedCategories.map((category) {
                return _WorldCategoryItem(
                  name: category,
                  onEdit: () => _showEditCategoryDialog(
                    context,
                    noteState,
                    category,
                  ),
                  onDelete: () => _showDeleteCategoryDialog(
                    context,
                    noteState,
                    category,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    NoteState noteState,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nowa kategoria świata'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Np. Religia, Frakcje, Lokacje...',
              labelText: 'Nazwa kategorii',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result != null) {
      await noteState.addWorldCategory(result);
    }
  }

  Future<void> _showEditCategoryDialog(
    BuildContext context,
    NoteState noteState,
    String oldName,
  ) async {
    final controller = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zmień nazwę kategorii'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nowa nazwa',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result != null && result != oldName) {
      await noteState.updateWorldCategory(oldName, result);
    }
  }

  Future<void> _showDeleteCategoryDialog(
    BuildContext context,
    NoteState noteState,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuń kategorię'),
          content: Text(
            'Czy na pewno chcesz usunąć kategorię "$name"?\n\n'
            'Wpisy z tej kategorii zostaną przeniesione do kategorii "Inne".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await noteState.removeWorldCategory(name);
    }
  }
}

class _NoteCategoriesSection extends StatefulWidget {
  const _NoteCategoriesSection({required this.noteState});

  final NoteState noteState;

  @override
  State<_NoteCategoriesSection> createState() =>
      _NoteCategoriesSectionState();
}

class _NoteCategoriesSectionState extends State<_NoteCategoriesSection> {
  final TextEditingController _controller = TextEditingController();
  Color _selectedColor = Colors.teal;

  static const _palette = [
    Colors.teal,
    Colors.indigo,
    Colors.orange,
    Colors.pinkAccent,
    Colors.lime,
    Colors.blueGrey,
    Colors.cyan,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.noteState.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories
              .map(
                (c) => InputChip(
                  label: Text(c.name),
                  avatar: CircleAvatar(backgroundColor: c.color, radius: 8),
                  onDeleted: () => widget.noteState.deleteCategory(c.id),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Nazwa nowej kategorii',
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _controller.clear();
                    }),
                  ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _palette
              .map(
                (color) => GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 14,
                    child: _selectedColor == color
                        ? const Icon(Icons.check, size: 16, color: Colors.black)
                        : null,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _addCategory,
            icon: const Icon(Icons.add),
            label: const Text('Dodaj kategorię'),
          ),
        ),
      ],
    );
  }

  Future<void> _addCategory() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    await widget.noteState.addCategory(
      NoteCategory(id: const Uuid().v4(), name: name, color: _selectedColor),
    );
    _controller.clear();
    if (mounted) setState(() {});
  }
}

class _WorldCategoryItem extends StatelessWidget {
  const _WorldCategoryItem({
    required this.name,
    required this.onEdit,
    required this.onDelete,
  });

  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(name),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Zmień nazwę',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Usuń kategorię',
            onPressed: onDelete,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _ColorPickerItem extends StatefulWidget {
  const _ColorPickerItem({
    required this.name,
    required this.color,
    required this.availableColors,
    required this.onColorChanged,
  });

  final String name;
  final Color color;
  final List<Color> availableColors;
  final Function(Color) onColorChanged;

  @override
  State<_ColorPickerItem> createState() => _ColorPickerItemState();
}

class _ColorPickerItemState extends State<_ColorPickerItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.availableColors.map((c) {
                // ignore: deprecated_member_use
                final isSelected = c.value == widget.color.value;
                return InkWell(
                  onTap: () => widget.onColorChanged(c),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.5,
                            )
                          : Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: _ColorPickerItemState._getContrastColor(c),
                            size: 16,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  static Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.white70),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShadowDemonLordSection extends StatefulWidget {
  const _ShadowDemonLordSection({required this.state});

  final NoteState state;

  @override
  State<_ShadowDemonLordSection> createState() =>
      _ShadowDemonLordSectionState();
}

class _ShadowDemonLordSectionState extends State<_ShadowDemonLordSection>
    with SingleTickerProviderStateMixin {
  String _query = '';
  String? _selectedCompendiumCategory;
  String? _selectedWorldCategory;
  String? _traditionFilter;
  String? _levelFilter;
  String? _typeFilter;
  ShadowDemonLordCompendium? _compendium;
  bool _isLoadingCompendium = true;
  int _displayLimit = 20;
  static const int _loadMoreIncrement = 20;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Odświeża FAB gdy zmienia się zakładka
    });
    _loadCompendium();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCompendium() async {
    try {
      final compendium = await ShadowDemonLordCompendium.loadFromAssets();
      if (mounted) {
        setState(() {
          _compendium = compendium;
          _isLoadingCompendium = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCompendium = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd ładowania kompendium: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCompendium) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Kompendium'),
          Tab(text: 'Notatki'),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Nowy wpis'),
              onPressed: () => _openEditor(null),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [_buildCompendiumView(), _buildNotesView()],
      ),
    );
  }

  Widget _buildCompendiumView() {
    final compendium = _compendium!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final markdownPreviewStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: scheme.onSurface,
      ),
      h1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        height: 1.3,
      ),
      h2: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        height: 1.3,
      ),
      h3: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        height: 1.3,
      ),
      strong: TextStyle(
        fontWeight: FontWeight.w700,
        color: scheme.primary,
      ),
      em: TextStyle(
        fontStyle: FontStyle.italic,
        color: scheme.secondary,
      ),
      listBullet: TextStyle(
        fontSize: 13,
        color: scheme.primary,
      ),
      tableHead: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: scheme.primary,
      ),
      tableBody: TextStyle(
        fontSize: 13,
        height: 1.35,
        color: scheme.onSurface,
      ),
      tableBorder: TableBorder.all(
        color: scheme.outlineVariant.withValues(alpha: .35),
        width: 1,
      ),
      blockquote: TextStyle(
        color: scheme.onSurface,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: .35),
        ),
      ),
      code: TextStyle(
        fontSize: 12,
        color: scheme.onSurface,
        backgroundColor: scheme.surfaceContainerHighest,
        fontFamily: 'monospace',
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: .35),
            width: 1,
          ),
        ),
      ),
    );

    List<CompendiumEntryWithCategory> entries;
    if (_selectedCompendiumCategory == null) {
      // Wszystkie wpisy ze wszystkich kategorii z informacją o kategorii
      entries = compendium.categories
          .expand(
            (cat) => cat.items.map(
              (item) => CompendiumEntryWithCategory(
                name: item.name,
                source: item.source,
                book: item.book,
                page: item.page,
                description: item.description,
                traditions: item.traditions,
                type: item.type,
                level: item.level,
                categoryName: cat.name,
              ),
            ),
          )
          .toList();
    } else {
      // Wpisy tylko z wybranej kategorii
      final selectedCat = compendium.categories.firstWhere(
        (c) => c.name == _selectedCompendiumCategory,
        orElse: () => compendium.categories.first,
      );
      entries = selectedCat.items
          .map(
            (item) => CompendiumEntryWithCategory(
              name: item.name,
              source: item.source,
              book: item.book,
              page: item.page,
              description: item.description,
              traditions: item.traditions,
              type: item.type,
              level: item.level,
              categoryName: selectedCat.name,
            ),
          )
          .toList();
    }

    final filtered = entries.where((e) {
      final lower = _query.toLowerCase();
      return _query.isEmpty ||
          e.name.toLowerCase().contains(lower) ||
          e.source.toLowerCase().contains(lower) ||
          e.book.toLowerCase().contains(lower);
    }).toList();

    // Apply tradition/type/level filters only when viewing the "Zaklęcia" category
    final afterFilters = (_selectedCompendiumCategory == 'Zaklęcia')
        ? filtered.where((e) {
            if (_traditionFilter != null &&
                (_traditionFilter ?? '').isNotEmpty) {
              final traditions = e.traditions ?? [];
              final matchesTradition = traditions.any(
                (t) => t.toUpperCase() == _traditionFilter!.toUpperCase(),
              );
              if (!matchesTradition) return false;
            }
            if (_typeFilter != null && (_typeFilter ?? '').isNotEmpty) {
              if (e.type == null) return false;
              if (e.type!.toUpperCase() != _typeFilter!.toUpperCase()) {
                return false;
              }
            }
            if (_levelFilter != null && (_levelFilter ?? '').isNotEmpty) {
              if (e.level == null) return false;
              if (e.level!.toString() != _levelFilter) return false;
            }
            return true;
          }).toList()
        : filtered;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Szukaj w kompendium...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() {
              _query = v;
              _displayLimit = 20;
            }),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Wszystkie'),
                  selected: _selectedCompendiumCategory == null,
                  onSelected: (_) => setState(() {
                    _selectedCompendiumCategory = null;
                    _displayLimit = 20;
                  }),
                ),
                ...compendium.categories.map((c) {
                  final color = widget.state.getCompendiumCategoryColor(c.name);
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(
                        c.name,
                        style: TextStyle(
                          color: _selectedCompendiumCategory == c.name
                              ? Colors.white
                              : Colors.white70,
                          fontWeight: _selectedCompendiumCategory == c.name
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      selected: _selectedCompendiumCategory == c.name,
                      backgroundColor: color.withValues(alpha: .15),
                      selectedColor: color.withValues(alpha: .35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: color.withValues(alpha: .3),
                          width: 1,
                        ),
                      ),
                      onSelected: (_) => setState(() {
                        _selectedCompendiumCategory = c.name;
                        _displayLimit = 20;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Show compact tradition/type/poziom filters only when user selected the 'Zaklęcia' category
          if (_selectedCompendiumCategory == 'Zaklęcia') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                spacing: 6,
                children: [
                  Expanded(
                    flex: 55,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: DropdownButtonFormField<String?>(
                        isDense: true,
                        isExpanded: true,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        iconSize: 18,
                        icon: Icon(
                          Icons.expand_more,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        dropdownColor: Theme.of(context).cardColor,
                        elevation: 6,
                        alignment: Alignment.centerLeft,
                        decoration: InputDecoration(
                          labelText: 'Tradycja',
                          isDense: true,
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .15),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        initialValue: _traditionFilter,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Wszystkie'),
                          ),
                          ...entries
                              .expand((e) => e.traditions ?? const <String>[])
                              .where((t) => t.isNotEmpty)
                              .map((t) => t.trim())
                              .where((t) => t.isNotEmpty)
                              .fold<Map<String, String>>(
                                {},
                                (acc, t) {
                                  final key = t.toUpperCase();
                                  acc[key] = t;
                                  return acc;
                                },
                              )
                              .values
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              ),
                        ],
                        onChanged: (v) => setState(() {
                          _traditionFilter = v;
                          _displayLimit = 20;
                        }),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: DropdownButtonFormField<String?>(
                        isDense: true,
                        isExpanded: true,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        iconSize: 18,
                        icon: Icon(
                          Icons.expand_more,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        dropdownColor: Theme.of(context).cardColor,
                        elevation: 6,
                        alignment: Alignment.centerLeft,
                        decoration: InputDecoration(
                          labelText: 'Typ',
                          isDense: true,
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .15),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        initialValue: _typeFilter,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Wszystkie'),
                          ),
                          ...entries
                              .map((e) => e.type ?? '')
                              .where((t) => t.isNotEmpty)
                              .toSet()
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              ),
                        ],
                        onChanged: (v) => setState(() {
                          _typeFilter = v;
                          _displayLimit = 20;
                        }),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 15,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: DropdownButtonFormField<String?>(
                        isDense: true,
                        isExpanded: true,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        iconSize: 18,
                        icon: Icon(
                          Icons.expand_more,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        dropdownColor: Theme.of(context).cardColor,
                        elevation: 6,
                        alignment: Alignment.centerLeft,
                        decoration: InputDecoration(
                          labelText: 'Poziom',
                          isDense: true,
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .15),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        initialValue: _levelFilter,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('○')),
                          ...entries
                              .map((e) => e.level?.toString() ?? '')
                              .where((t) => t.isNotEmpty)
                              .toSet()
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              ),
                        ],
                        onChanged: (v) => setState(() {
                          _levelFilter = v;
                          _displayLimit = 20;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Razem: ${entries.length} | Wyfiltrowanych: ${afterFilters.length}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: afterFilters.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Brak wpisów w tej kategorii'),
                              const SizedBox(height: 8),
                              Text(
                                'Załadowanych wpisów: ${entries.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: afterFilters.length > _displayLimit
                              ? _displayLimit
                              : afterFilters.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = afterFilters[index];
                            final entryColor = widget.state
                                .getCompendiumCategoryColor(entry.categoryName);
                            final entryMarkdownStyle = markdownPreviewStyle
                                .copyWith(
                                  strong: markdownPreviewStyle.strong?.copyWith(
                                        color: entryColor,
                                      ) ??
                                      TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: entryColor,
                                      ),
                                );

                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _CompendiumEntryDetailsPage(
                                      entry: entry,
                                      state: widget.state,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .04),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (entry.description.isNotEmpty)
                                      SizedBox(
                                        height: 110,
                                        child: ClipRect(
                                          child: Scrollbar(
                                            thumbVisibility: false,
                                            child: SingleChildScrollView(
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              child: MarkdownBody(
                                                data: entry.description,
                                                extensionSet: md
                                                    .ExtensionSet.gitHubFlavored,
                                                softLineBreak: true,
                                                shrinkWrap: true,
                                                styleSheet: entryMarkdownStyle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (entry.description.isNotEmpty)
                                      const SizedBox(height: 10),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: widget.state
                                                .getBookColor(entry.book)
                                                .withValues(alpha: .18),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: widget.state
                                                  .getBookColor(entry.book)
                                                  .withValues(alpha: .3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: widget.state
                                                    .getBookColor(entry.book),
                                                radius: 4,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                entry.page > 0
                                                    ? '${entry.book} - str ${entry.page}'
                                                    : entry.book,
                                                style: TextStyle(
                                                  color: widget.state
                                                      .getBookColor(entry.book),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: entryColor.withValues(
                                              alpha: .18,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: entryColor.withValues(
                                                alpha: .3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: entryColor,
                                                radius: 4,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                entry.categoryName,
                                                style: TextStyle(
                                                  color: entryColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (entry.categoryName == 'Zaklęcia' &&
                                          ((entry.traditions != null &&
                                              entry.traditions!
                                                .isNotEmpty) ||
                                            entry.type != null ||
                                            entry.level != null))
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: entryColor.withValues(
                                                alpha: .18,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: entryColor.withValues(
                                                  alpha: .3,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: entryColor,
                                                  radius: 4,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  [
                                                    if (entry.traditions !=
                                                            null &&
                                                        entry.traditions!
                                                            .isNotEmpty)
                                                      entry.traditions!
                                                          .join(', '),
                                                    if (entry.type != null)
                                                      entry.type,
                                                    if (entry.level != null)
                                                      'Poz ${entry.level}',
                                                  ].join(', '),
                                                  style: TextStyle(
                                                    color: entryColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (filtered.length > _displayLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.expand_more),
                      onPressed: () {
                        setState(() {
                          _displayLimit += _loadMoreIncrement;
                        });
                      },
                      label: Text(
                        'Załaduj więcej ($_displayLimit/${filtered.length})',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesView() {
    final entries = _filteredEntries();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Szukaj w świecie...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          _WorldCategoryFilter(
            categories: widget.state.worldCategories,
            selected: _selectedWorldCategory,
            onSelected: (c) => setState(() => _selectedWorldCategory = c),
            state: widget.state,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: widget.state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _WorldEntryCard(
                        entry: entry,
                        state: widget.state,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WorldEntryDetailsPage(
                                entry: entry,
                                onEdit: () {
                                  Navigator.of(context).pop();
                                  _openEditor(entry);
                                },
                                onDelete: () {
                                  widget.state.deleteWorldEntry(entry.id);
                                },
                              ),
                            ),
                          );
                        },
                        onDelete: () => widget.state.deleteWorldEntry(entry.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<WorldEntry> _filteredEntries() {
    final lower = _query.toLowerCase();
    return widget.state.worldEntries.where((entry) {
      final matchesQuery =
          _query.isEmpty ||
          entry.title.toLowerCase().contains(lower) ||
          entry.description.toLowerCase().contains(lower) ||
          entry.category.toLowerCase().contains(lower);
      final matchesCategory =
          _selectedWorldCategory == null ||
          entry.category == _selectedWorldCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<void> _openEditor(WorldEntry? existing) async {
    final isNew = existing == null;
    final entry = existing ?? widget.state.createBlankWorldEntry();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _WorldEntryEditorPage(
          entry: entry,
          isNew: isNew,
          state: widget.state,
        ),
      ),
    );
  }
}

class _WorldCategoryFilter extends StatelessWidget {
  const _WorldCategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.state,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final NoteState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Wszystkie'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          ...categories.map((c) {
            final color = state.getCompendiumCategoryColor(c);
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(
                  c,
                  style: TextStyle(
                    color: selected == c ? Colors.white : Colors.white70,
                    fontWeight: selected == c
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                selected: selected == c,
                backgroundColor: color.withValues(alpha: .15),
                selectedColor: color.withValues(alpha: .35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: color.withValues(alpha: .3),
                    width: 1,
                  ),
                ),
                onSelected: (_) => onSelected(c),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WorldEntryCard extends StatelessWidget {
  const _WorldEntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
    required this.state,
  });

  final WorldEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final NoteState state;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM HH:mm');
    final color = state.getCompendiumCategoryColor(entry.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: .04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.description.isEmpty
                            ? 'Brak opisu'
                            : entry.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(backgroundColor: color, radius: 4),
                      const SizedBox(width: 6),
                      Text(
                        entry.category,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  formatter.format(entry.updatedAt),
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySheet extends StatefulWidget {
  const _CategorySheet({required this.state});
  final NoteState state;

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = Colors.teal;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = [
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.pinkAccent,
      Colors.lime,
      Colors.blueGrey,
      Colors.cyan,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategorie',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.state.categories
                .map(
                  (c) => Chip(
                    label: Text(c.name),
                    backgroundColor: c.color.withValues(alpha: .2),
                    avatar: CircleAvatar(backgroundColor: c.color, radius: 8),
                    onDeleted: () => widget.state.deleteCategory(c.id),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Nazwa nowej kategorii',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: palette
                .map(
                  (color) => GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 14,
                      child: _selectedColor == color
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black,
                            )
                          : null,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addCategory,
              child: const Text('Dodaj kategorię'),
            ),
          ),
        ],
      ),
    );
  }

  void _addCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.state.addCategory(
      NoteCategory(id: const Uuid().v4(), name: name, color: _selectedColor),
    );
    _nameController.clear();
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  final NoteItem note;
  final NoteCategory? category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM HH:mm');
    final colorScheme = Theme.of(context).colorScheme;

    final (
      String importanceLabel,
      Color importanceColor,
    ) = switch (note.importance) {
      NoteImportance.low => (
        'Niska',
        colorScheme.onSurface.withValues(alpha: .5),
      ),
      NoteImportance.normal => (
        'Normalna',
        colorScheme.primary.withValues(alpha: .7),
      ),
      NoteImportance.high => (
        'Wysoka',
        colorScheme.error.withValues(alpha: .8),
      ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: .04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (note.iconCodePoint != null) ...[
                            Icon(
                              IconData(
                                note.iconCodePoint!,
                                fontFamily: 'MaterialIcons',
                              ),
                              size: 18,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: importanceColor.withValues(alpha: .18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: importanceColor.withValues(alpha: .35),
                              ),
                            ),
                            child: Text(
                              importanceLabel,
                              style: TextStyle(
                                color: importanceColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note.body.isEmpty ? 'Brak treści' : note.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (category != null && category!.id.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: category!.color.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: category!.color,
                          radius: 4,
                        ),
                        const SizedBox(width: 6),
                        Text(category!.name),
                      ],
                    ),
                  ),
                const Spacer(),
                if (note.imagePath != null)
                  const Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: Colors.white54,
                  ),
                if (note.imagePath != null) const SizedBox(width: 8),
                if (note.audioPath != null)
                  const Icon(Icons.mic, size: 18, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Text(
                  formatter.format(note.updatedAt),
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<NoteCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Wszystkie'),
            selected: selectedId == null,
            onSelected: (_) => onSelected(null),
          ),
          ...categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(
                  c.name,
                  style: TextStyle(
                    color: selectedId == c.id ? Colors.white : Colors.white70,
                    fontWeight: selectedId == c.id
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                selected: selectedId == c.id,
                backgroundColor: c.color.withValues(alpha: .15),
                selectedColor: c.color.withValues(alpha: .35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: c.color.withValues(alpha: .3),
                    width: 1,
                  ),
                ),
                onSelected: (_) => onSelected(c.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Brak notatek. Dodaj pierwszą, by zacząć zapisywać sesję.'),
    );
  }
}

class _WorldEntryEditorPage extends StatefulWidget {
  const _WorldEntryEditorPage({
    required this.entry,
    required this.isNew,
    required this.state,
  });

  final WorldEntry entry;
  final bool isNew;
  final NoteState state;

  @override
  State<_WorldEntryEditorPage> createState() => _WorldEntryEditorPageState();
}

class _WorldEntryEditorPageState extends State<_WorldEntryEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _descController = TextEditingController(text: widget.entry.description);
    _selectedCategory = widget.entry.category.isEmpty
        ? null
        : widget.entry.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Nowy wpis' : 'Edytuj wpis'),
        actions: [
          IconButton(
            tooltip: 'Dodaj kategorię',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addCategory,
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tytuł',
                hintText: 'Wpisz tytuł...',
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (widget.state.worldCategories.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: .3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[300]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Dodaj najpierw kategorię używając przycisku +',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Kategoria'),
                initialValue: _selectedCategory,
                items: widget.state.worldCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedCategory = v);
                },
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Opis / Informacje',
                hintText: 'Wpisz szczegóły, notatki, dodatkowe informacje...',
                alignLabelWithHint: true,
              ),
              minLines: 8,
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nowa kategoria świata'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Np. Religia'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result != null) {
      await widget.state.addWorldCategory(result);
      setState(() => _selectedCategory = result);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tytuł jest wymagany')));
      return;
    }

    if (widget.state.worldCategories.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dodaj najpierw kategorię')));
      return;
    }

    final updated = WorldEntry(
      id: widget.entry.id,
      title: title,
      category: _selectedCategory!,
      description: _descController.text.trim(),
      createdAt: widget.entry.createdAt,
      updatedAt: DateTime.now(),
    );

    await widget.state.addOrUpdateWorldEntry(updated);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({required this.note, required this.isNew, super.key});

  final NoteItem note;
  final bool isNew;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  String? _selectedCategoryId;
  String? _audioPath;
  String? _transcript;
  String? _imagePath;
  String? _pendingImageSourcePath;
  String? _imagePathToDeleteOnSave;
  int? _iconCodePoint;
  NoteImportance _importance = NoteImportance.normal;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isListening = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  String _dictationBaseText = '';

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  late final stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _bodyController = TextEditingController(text: widget.note.body);
    _selectedCategoryId = widget.note.categoryId;
    _audioPath = widget.note.audioPath;
    _transcript = widget.note.transcript;
    _imagePath = widget.note.imagePath;
    _iconCodePoint = widget.note.iconCodePoint;
    _importance = widget.note.importance;
    _speech = stt.SpeechToText();
    _player.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
    _player.durationStream.listen((d) {
      if (d == null) return;
      setState(() => _audioDuration = d);
    });
    _player.positionStream.listen((p) {
      setState(() => _audioPosition = p);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _player.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NoteState>();
    final shownImagePath = _pendingImageSourcePath ?? _imagePath;
    final selectedIcon = _iconCodePoint == null
        ? null
        : IconData(_iconCodePoint!, fontFamily: 'MaterialIcons');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Nowa notatka' : 'Edytuj notatkę'),
        actions: [
          IconButton(
            tooltip: 'Zapisz',
            icon: const Icon(Icons.check),
            onPressed: () => _save(state),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Tytuł'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(labelText: 'Kategoria'),
              initialValue: _selectedCategoryId,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: const Text('Brak'),
                ),
                ...state.categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showIconPicker,
                    icon: Icon(selectedIcon ?? Icons.emoji_symbols_outlined),
                    label: Text(
                      selectedIcon == null ? 'Dodaj ikonę' : 'Zmień ikonę',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<NoteImportance>(
                    decoration: const InputDecoration(labelText: 'Ważność'),
                    initialValue: _importance,
                    items: const [
                      DropdownMenuItem(
                        value: NoteImportance.low,
                        child: Text('Niska'),
                      ),
                      DropdownMenuItem(
                        value: NoteImportance.normal,
                        child: Text('Normalna'),
                      ),
                      DropdownMenuItem(
                        value: NoteImportance.high,
                        child: Text('Wysoka'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _importance = v);
                    },
                  ),
                ),
                if (selectedIcon != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Usuń ikonę',
                    onPressed: () => setState(() => _iconCodePoint = null),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              minLines: 8,
              maxLines: 14,
              decoration: const InputDecoration(hintText: 'Treść notatki'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      shownImagePath == null ? 'Dodaj obraz' : 'Zmień obraz',
                    ),
                    onPressed: _pickImage,
                  ),
                ),
                if (shownImagePath != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Usuń obraz',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _clearImage,
                  ),
                ],
              ],
            ),
            if (shownImagePath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(shownImagePath),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      alignment: Alignment.center,
                      color: Theme.of(context).cardColor,
                      child: const Text('Nie udało się wczytać obrazu.'),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    label: Text(_isRecording ? 'Stop' : 'Nagraj głos'),
                    onPressed: _toggleRecording,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      _isListening ? Icons.hearing_disabled : Icons.hearing,
                    ),
                    label: Text(_isListening ? 'Zakończ' : 'Dyktuj'),
                    onPressed: _toggleDictation,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_audioPath != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Załączono nagranie',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle : Icons.play_circle,
                        ),
                        onPressed: _togglePlayback,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final path = _audioPath;
                          setState(() => _audioPath = null);
                          if (path == null) return;
                          try {
                            final f = File(path);
                            if (await f.exists()) await f.delete();
                          } catch (_) {
                            // ignore
                          }
                        },
                      ),
                    ],
                  ),
                  Slider(
                    value: _audioPosition.inMilliseconds
                        .clamp(0, _audioDuration.inMilliseconds)
                        .toDouble(),
                    max: _audioDuration.inMilliseconds == 0
                        ? 1
                        : _audioDuration.inMilliseconds.toDouble(),
                    onChanged: (v) async {
                      if (_audioDuration.inMilliseconds == 0) return;
                      final newPos = Duration(milliseconds: v.toInt());
                      await _player.seek(newPos);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_audioPosition),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatDuration(_audioDuration),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            if (_transcript != null && _transcript!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Transkrypcja',
                style: TextStyle(color: Colors.white.withValues(alpha: .7)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_transcript!),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _save(NoteState state) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tytuł nie może być pusty.')),
      );
      return;
    }

    String? finalImagePath = _imagePath;
    if (_pendingImageSourcePath != null) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${dir.path}/note_images');
        await imagesDir.create(recursive: true);

        final sourcePath = _pendingImageSourcePath!;
        final filename = Uri.file(sourcePath).pathSegments.isEmpty
            ? ''
            : Uri.file(sourcePath).pathSegments.last;
        final dot = filename.lastIndexOf('.');
        final ext = dot >= 0 ? filename.substring(dot) : '.img';

        final targetPath =
            '${imagesDir.path}/${widget.note.id}_${DateTime.now().millisecondsSinceEpoch}$ext';
        await File(sourcePath).copy(targetPath);

        _imagePathToDeleteOnSave ??= _imagePath;
        finalImagePath = targetPath;
      } catch (e) {
        _toast('Nie udało się zapisać obrazu: $e');
        return;
      }
    }

    final oldToDelete = _imagePathToDeleteOnSave;
    if (oldToDelete != null && oldToDelete.isNotEmpty) {
      try {
        final f = File(oldToDelete);
        if (await f.exists()) await f.delete();
      } catch (_) {
        // ignore
      }
    }

    widget.note
      ..title = _titleController.text.trim()
      ..body = _bodyController.text.trim()
      ..categoryId = _selectedCategoryId
      ..audioPath = _audioPath
      ..transcript = _transcript
      ..imagePath = finalImagePath
      ..iconCodePoint = _iconCodePoint
      ..importance = _importance;

    await state.addOrUpdateNote(widget.note);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final pickedPath = result.files.single.path;
    if (pickedPath == null) return;

    setState(() {
      if (_imagePath != null) {
        _imagePathToDeleteOnSave ??= _imagePath;
      }
      _pendingImageSourcePath = pickedPath;
    });
  }

  void _clearImage() {
    setState(() {
      if (_imagePath != null) {
        _imagePathToDeleteOnSave ??= _imagePath;
      }
      _imagePath = null;
      _pendingImageSourcePath = null;
    });
  }

  Future<void> _showIconPicker() async {
    const icons = <IconData>[
      Icons.person,
      Icons.group,
      Icons.location_on,
      Icons.shield,
      Icons.auto_fix_high,
      Icons.book,
      Icons.inventory_2,
      Icons.bolt,
      Icons.pets,
      Icons.castle,
      Icons.forest,
      Icons.public,
    ];

    final selected = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: const Color(0xFF141820),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Wybierz ikonę',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Brak'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final icon in icons)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(icon.codePoint),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .06),
                          ),
                        ),
                        child: Icon(icon),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() => _iconCodePoint = selected);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _audioPath = path;
        _isRecording = false;
      });
      return;
    }

    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak uprawnień do mikrofonu.')),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final voiceDir = Directory('${dir.path}/voice_notes');
    await voiceDir.create(recursive: true);

    final bool useAac =
        Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
    final String extension = useAac ? '.m4a' : '.wav';
    final filePath =
        '${voiceDir.path}/${widget.note.id}_${DateTime.now().millisecondsSinceEpoch}$extension';

    final RecordConfig config = RecordConfig(
      encoder: useAac ? AudioEncoder.aacLc : AudioEncoder.wav,
      sampleRate: useAac ? 44100 : 16000,
    );

    await _recorder.start(config, path: filePath);
    setState(() => _isRecording = true);
  }

  Future<void> _togglePlayback() async {
    if (_audioPath == null) return;
    if (_isPlaying) {
      await _player.stop();
      return;
    }
    await _player.setFilePath(_audioPath!);
    await _player.play();
  }

  Future<void> _toggleDictation() async {
    if (_isRecording) {
      _toast('Zatrzymaj nagrywanie przed dyktowaniem.');
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _dictationBaseText = _bodyController.text;
      });
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        // Speech engine may stop on its own.
        if (status == 'done' || status == 'notListening') {
          if (!mounted) return;
          setState(() => _isListening = false);
        }
      },
    );
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mikrofon niedostępny.')));
      return;
    }

    String? localeId;
    try {
      final locales = await _speech.locales();
      final pl = locales.where(
        (l) => l.localeId.toLowerCase().startsWith('pl'),
      );
      if (pl.isNotEmpty) localeId = pl.first.localeId;
    } catch (_) {
      // ignore
    }

    _dictationBaseText = _bodyController.text;
    setState(() => _isListening = true);
    await _speech.listen(
      localeId: localeId,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
      onResult: (result) {
        final words = result.recognizedWords.trim();
        if (!mounted) return;

        final base = _dictationBaseText;
        final String nextText;
        if (base.isEmpty || base.endsWith(' ') || base.endsWith('\n')) {
          nextText = words.isEmpty ? base : '$base$words';
        } else {
          nextText = words.isEmpty ? base : '$base $words';
        }

        setState(() => _transcript = words);
        _bodyController.text = nextText;
        _bodyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _bodyController.text.length),
        );

        if (result.finalResult) {
          // Keep listening; treat this as a committed chunk.
          final committed = _bodyController.text;
          if (committed.isNotEmpty &&
              !committed.endsWith(' ') &&
              !committed.endsWith('\n')) {
            _dictationBaseText = '$committed ';
          } else {
            _dictationBaseText = committed;
          }
        }
      },
    );
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    final hours = d.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}

class _CompendiumEntryDetailsPage extends StatefulWidget {
  final CompendiumEntryWithCategory entry;
  final NoteState state;

  const _CompendiumEntryDetailsPage({required this.entry, required this.state});

  @override
  State<_CompendiumEntryDetailsPage> createState() =>
      _CompendiumEntryDetailsPageState();
}

class _CompendiumEntryDetailsPageState
    extends State<_CompendiumEntryDetailsPage> {
  String? _markdownContent;
  bool _isLoadingMarkdown = false;

  @override
  void initState() {
    super.initState();
    _loadMarkdownIfAvailable();
  }

  Future<void> _loadMarkdownIfAvailable() async {
    if (widget.entry.markdownPath != null &&
        widget.entry.markdownPath!.isNotEmpty) {
      setState(() {
        _isLoadingMarkdown = true;
      });

      try {
        final content =
            await rootBundle.loadString(widget.entry.markdownPath!);
        if (mounted) {
          setState(() {
            _markdownContent = content;
            _isLoadingMarkdown = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingMarkdown = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        widget.state.getCompendiumCategoryColor(widget.entry.categoryName);
    final bookColor = widget.state.getBookColor(widget.entry.book);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaceCard = Color.alphaBlend(
      scheme.primary.withValues(alpha: .05),
      scheme.surfaceContainerHighest,
    );
    final borderColor = scheme.outlineVariant.withValues(alpha: .4);
    final markdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: TextStyle(
        fontSize: 16,
        height: 1.6,
        letterSpacing: 0.2,
        color: scheme.onSurface,
      ),
      h1: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
        height: 1.35,
      ),
      h2: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        height: 1.35,
      ),
      h3: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        height: 1.35,
      ),
      strong: TextStyle(
        fontWeight: FontWeight.w700,
        color: scheme.primary,
      ),
      em: TextStyle(
        fontStyle: FontStyle.italic,
        color: scheme.secondary,
      ),
      listBullet: TextStyle(
        fontSize: 16,
        color: scheme.primary,
      ),
      tableHead: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: scheme.primary,
      ),
      tableBody: TextStyle(
        fontSize: 15,
        height: 1.5,
        color: scheme.onSurface,
      ),
      tableBorder: TableBorder.all(
        color: borderColor,
        width: 1,
      ),
      tableCellsPadding: const EdgeInsets.all(10),
      blockquote: TextStyle(
        color: scheme.onSurface,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      code: TextStyle(
        fontSize: 14,
        color: scheme.onSurface,
        backgroundColor: scheme.surfaceContainerHighest,
        fontFamily: 'monospace',
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141820),
        elevation: 0,
        title: Text(
          widget.entry.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tytuł
            Text(
              widget.entry.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Badge'y
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Badge kategorii
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: .3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(backgroundColor: categoryColor, radius: 5),
                      const SizedBox(width: 8),
                      Text(
                        widget.entry.categoryName,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge podręcznika
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: bookColor.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: bookColor.withValues(alpha: .3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(backgroundColor: bookColor, radius: 5),
                      const SizedBox(width: 8),
                      Text(
                        widget.entry.page > 0
                            ? '${widget.entry.book} - str ${widget.entry.page}'
                            : widget.entry.book,
                        style: TextStyle(
                          color: bookColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge tradycji/typu/poziomu (tylko dla zaklęć)
                if (widget.entry.traditions != null &&
                    widget.entry.traditions!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: .3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(backgroundColor: categoryColor, radius: 5),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.entry.traditions!.join(', ')}${widget.entry.type != null ? ', ${widget.entry.type}' : ''}${widget.entry.level != null ? ', Poz ${widget.entry.level}' : ''}',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Badge strony zaklęcia (jeśli istnieje)
                // REMOVED: Page is now shown in source badge above
              ],
            ),
            const SizedBox(height: 24),

            // Opis - z markdown lub JSON
            if (_isLoadingMarkdown)
              const Center(child: CircularProgressIndicator())
            else if (_markdownContent != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: MarkdownBody(
                  data: _markdownContent!,
                  extensionSet: md.ExtensionSet.gitHubFlavored,
                  softLineBreak: true,
                  styleSheet: markdownStyle.copyWith(
                    strong: markdownStyle.strong?.copyWith(
                          color: categoryColor,
                        ) ??
                        TextStyle(
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                        ),
                  ),
                ),
              ),
            ] else if (widget.entry.description.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: MarkdownBody(
                  data: widget.entry.description,
                  extensionSet: md.ExtensionSet.gitHubFlavored,
                  softLineBreak: true,
                  styleSheet: markdownStyle.copyWith(
                    strong: markdownStyle.strong?.copyWith(
                          color: categoryColor,
                        ) ??
                        TextStyle(
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                        ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Brak opisu dla tego wpisu',
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
