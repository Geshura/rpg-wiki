enum NoteImportance {
  low,
  normal,
  high,
}

NoteImportance noteImportanceFromJson(dynamic value) {
  final raw = value?.toString().trim().toLowerCase();
  return switch (raw) {
    'low' => NoteImportance.low,
    'high' => NoteImportance.high,
    'normal' => NoteImportance.normal,
    _ => NoteImportance.normal,
  };
}

class NoteItem {
  NoteItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.audioPath,
    this.transcript,
    this.imagePath,
    this.iconCodePoint,
    this.importance = NoteImportance.normal,
  });

  final String id;
  String title;
  String body;
  String? categoryId;
  String? audioPath;
  String? transcript;
  String? imagePath;
  int? iconCodePoint;
  NoteImportance importance;
  DateTime createdAt;
  DateTime updatedAt;

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    final iconValue = json['iconCodePoint'];
    return NoteItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      audioPath: json['audioPath'] as String?,
      transcript: json['transcript'] as String?,
      imagePath: json['imagePath'] as String?,
      iconCodePoint: iconValue is int
          ? iconValue
          : iconValue is num
          ? iconValue.toInt()
          : null,
      importance: noteImportanceFromJson(json['importance']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'categoryId': categoryId,
      'audioPath': audioPath,
      'transcript': transcript,
      'imagePath': imagePath,
      'iconCodePoint': iconCodePoint,
      'importance': importance.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NoteItem copyWith({
    String? title,
    String? body,
    String? categoryId,
    String? audioPath,
    String? transcript,
    String? imagePath,
    int? iconCodePoint,
    NoteImportance? importance,
  }) {
    return NoteItem(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      categoryId: categoryId ?? this.categoryId,
      audioPath: audioPath ?? this.audioPath,
      transcript: transcript ?? this.transcript,
      imagePath: imagePath ?? this.imagePath,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      importance: importance ?? this.importance,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
