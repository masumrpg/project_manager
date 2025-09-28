import 'package:hive/hive.dart';

import 'enums/content_type.dart';
import 'enums/note_status.dart';

part 'note.g.dart';

@HiveType(typeId: 11)
class Note extends HiveObject {
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.contentType,
    this.status = NoteStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  ContentType contentType;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  NoteStatus status;

  Note copyWith({
    String? title,
    String? content,
    ContentType? contentType,
    NoteStatus? status,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
