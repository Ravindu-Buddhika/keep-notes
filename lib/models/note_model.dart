class NoteModel {
  final int? id;
  final String title;
  final String content;
  final String color;
  final String? aiSummary;
  final String createdAt;
  final String updatedAt;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    required this.color,
    this.aiSummary,
    required this.createdAt,
    required this.updatedAt,
  });


  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      color: map['color'],
      aiSummary: map['ai_summary'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'ai_summary': aiSummary,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}