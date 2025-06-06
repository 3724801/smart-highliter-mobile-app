class Highlight {
  final String id;
  final String selectedText;
  final String pageTitle;
  final String pageUrl;
  final String? note;
  final String? aiAnalysis;
  final String color;
  final List<String> tags;
  final String? userId;
  final String timestamp;

  Highlight({
    required this.id,
    required this.selectedText,
    required this.pageTitle,
    required this.pageUrl,
    this.note,
    this.aiAnalysis,
    required this.color,
    required this.tags,
    this.userId,
    required this.timestamp,
  });

  // Add a copyWith method for convenience
  Highlight copyWith({
    String? id,
    String? selectedText,
    String? pageTitle,
    String? pageUrl,
    String? note,
    String? aiAnalysis,
    String? color,
    List<String>? tags,
    String? userId,
    String? timestamp,
  }) {
    return Highlight(
      id: id ?? this.id,
      selectedText: selectedText ?? this.selectedText,
      pageTitle: pageTitle ?? this.pageTitle,
      pageUrl: pageUrl ?? this.pageUrl,
      note: note ?? this.note,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Improved fromJson with null safety and debugging
  factory Highlight.fromJson(Map<String, dynamic> json) {
    // Add debug prints to trace the issue
    print('Processing highlight JSON: ${json['id']}, userId: ${json['userId']}');

    // Handle tags safely - this is a common source of errors
    List<String> parsedTags = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        parsedTags = List<String>.from(json['tags'].map((tag) => tag.toString()));
      } else if (json['tags'] is String) {
        // Handle case where tags might be a comma-separated string
        parsedTags = (json['tags'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    return Highlight(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      selectedText: json['selectedText']?.toString() ?? '',
      pageTitle: json['pageTitle']?.toString() ?? '',
      pageUrl: json['pageUrl']?.toString() ?? '',
      note: json['note']?.toString(),
      aiAnalysis: json['aiAnalysis']?.toString(),
      color: json['color']?.toString() ?? 'yellow',
      tags: parsedTags,
      userId: json['userId']?.toString(), // Ensure consistent string format
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  // To JSON method with null handling
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'selectedText': selectedText,
      'pageTitle': pageTitle,
      'pageUrl': pageUrl,
      'note': note,
      'aiAnalysis': aiAnalysis,
      'color': color,
      'tags': tags,
      'userId': userId,
      'timestamp': timestamp,
    };
  }

  // Add equality and toString methods for better debugging
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Highlight &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Highlight{id: $id, title: $pageTitle, userId: $userId}';
  }
}