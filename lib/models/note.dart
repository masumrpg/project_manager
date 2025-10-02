import 'dart:convert';

import 'enums/note_status.dart';

class Note {
  Note({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.content,
    this.status = NoteStatus.draft,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;
  String projectId;
  String title;
  String content;
  String? description;
  DateTime createdAt;
  DateTime updatedAt;
  NoteStatus status;

  factory Note.fromJson(Map<String, dynamic> json, {String? fallbackProjectId}) {
    return Note(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? fallbackProjectId ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      content: _encodeContent(json['content']),
      status: NoteStatusX.fromApiValue(json['status'] as String? ?? 'draft'),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toApiPayload() {
    return {
      'title': title,
      if (description != null && description!.trim().isNotEmpty)
        'description': description,
      'content': _decodeContent(),
      'status': status.apiValue,
    };
  }

  Note copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? content,
    NoteStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _encodeContent(dynamic content) {
    if (content == null) return '[]';
    if (content is String) return content;
    try {
      return jsonEncode(content);
    } catch (_) {
      return content.toString();
    }
  }

  dynamic _decodeContent() {
    if (content.isEmpty) {
      return [];
    }

    try {
      return jsonDecode(content);
    } catch (_) {
      return content;
    }
  }
}
