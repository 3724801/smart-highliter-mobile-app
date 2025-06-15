// lib/models/Highlight.dart
import 'package:mongo_dart/mongo_dart.dart';

class Highlight {
  final String id;
  final String userId;
  final String selectedText;
  final String pageTitle;
  final String pageUrl;
  final String color;
  final String? note;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Highlight({
    required this.id,
    required this.userId,
    required this.selectedText,
    required this.pageTitle,
    required this.pageUrl,
    required this.color,
    this.note,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  // Create Highlight from MongoDB document
  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['_id'] is ObjectId
          ? json['_id'].toHexString()
          : json['_id'].toString(),
      userId: json['userId'] ?? '',
      selectedText: json['selectedText'] ?? '',
      pageTitle: json['pageTitle'] ?? '',
      pageUrl: json['pageUrl'] ?? '',
      color: json['color'] ?? 'yellow',
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'])
              : json['updatedAt'] as DateTime?)
          : null,
    );
  }

  // Convert Highlight to MongoDB document
  Map<String, dynamic> toJson() {
    return {
      '_id': ObjectId.fromHexString(id),
      'userId': userId,
      'selectedText': selectedText,
      'pageTitle': pageTitle,
      'pageUrl': pageUrl,
      'color': color,
      'note': note,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a new highlight document for insertion (without _id)
  Map<String, dynamic> toInsertJson() {
    return {
      'userId': userId,
      'selectedText': selectedText,
      'pageTitle': pageTitle,
      'pageUrl': pageUrl,
      'color': color,
      'note': note,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  Highlight copyWith({
    String? id,
    String? userId,
    String? selectedText,
    String? pageTitle,
    String? pageUrl,
    String? color,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Highlight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      selectedText: selectedText ?? this.selectedText,
      pageTitle: pageTitle ?? this.pageTitle,
      pageUrl: pageUrl ?? this.pageUrl,
      color: color ?? this.color,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Highlight{id: $id, userId: $userId, selectedText: $selectedText, pageTitle: $pageTitle}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Highlight && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
