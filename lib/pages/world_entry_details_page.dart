import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/world_entry.dart';
import '../models/category_colors.dart';

class WorldEntryDetailsPage extends StatelessWidget {
  const WorldEntryDetailsPage({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final WorldEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    final color = CategoryColors.getWorldCategoryColor(entry.category);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f1115),
        elevation: 0,
        title: const Text('Szczegóły wpisu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edytuj',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Usuń',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Usuń wpis?'),
                  content: Text('Czy na pewno chcesz usunąć "${entry.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Anuluj'),
                    ),
                    TextButton(
                      onPressed: () {
                        onDelete();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Usuń', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tytuł
            Text(
              entry.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Kategoria badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: .3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: color,
                    radius: 5,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.category,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: .1),
            ),
            const SizedBox(height: 24),

            // Treść
            Text(
              entry.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFFDDDDDD),
              ),
            ),
            const SizedBox(height: 32),

            // Divider
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: .1),
            ),
            const SizedBox(height: 16),

            // Metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utworzono',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(entry.createdAt),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Zaktualizowano',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(entry.updatedAt),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
