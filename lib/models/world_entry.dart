/// World/setting entry for the Cień Władcy Demonów section.
class WorldEntry {
  WorldEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  String title;
  String category;
  String description;
  DateTime createdAt;
  DateTime updatedAt;

  factory WorldEntry.fromJson(Map<String, dynamic> json) {
    return WorldEntry(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Inne',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WorldEntry copyWith({
    String? title,
    String? category,
    String? description,
  }) {
    return WorldEntry(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}