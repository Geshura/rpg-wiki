import 'package:flutter/material.dart';

class NoteCategory {
  NoteCategory({required this.id, required this.name, required this.color});

  final String id;
  String name;
  Color color;

  factory NoteCategory.fromJson(Map<String, dynamic> json) {
    return NoteCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'color': color.toARGB32()};
  }
}
