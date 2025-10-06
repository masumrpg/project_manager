import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums/note_status.dart';

part 'note.freezed.dart';
part 'note.g.dart';

class NoteContentConverter implements JsonConverter<String, dynamic> {
  const NoteContentConverter();

  @override
  String fromJson(dynamic json) {
    if (json == null) return '[]';
    if (json is String) return json;
    try {
      return jsonEncode(json);
    } catch (_) {
      return json.toString();
    }
  }

  @override
  dynamic toJson(String object) {
    if (object.isEmpty) return [];
    try {
      return jsonDecode(object);
    } catch (_) {
      return object;
    }
  }
}

@freezed
class Note with _$Note {
    const Note._();

    const factory Note({
        required String id,
        required String projectId,
        required String title,
        String? description,
        @NoteContentConverter() required String content,
        @Default(NoteStatus.draft) NoteStatus status,
        required DateTime createdAt,
        required DateTime updatedAt,
    }) = _Note;

    factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

    Map<String, dynamic> toApiPayload() {
        return {
            'title': title,
            if (description != null && description!.trim().isNotEmpty)
                'description': description,
            'content': const NoteContentConverter().toJson(content),
            'status': status.apiValue,
        };
    }
}