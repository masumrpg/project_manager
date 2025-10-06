import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums/app_category.dart';
import 'enums/environment.dart';
import 'note.dart';
import 'revision.dart';
import 'todo.dart';

part 'project.freezed.dart';
part 'project.g.dart';

// Custom converter for the longDescription field
class LongDescriptionConverter implements JsonConverter<String?, dynamic> {
  const LongDescriptionConverter();

  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    try {
      return jsonEncode(json);
    } catch (_) {
      return json.toString();
    }
  }

  @override
  dynamic toJson(String? object) {
    if (object == null || object.isEmpty) return null;
    try {
      return jsonDecode(object);
    } catch (_) {
      return object;
    }
  }
}

@freezed
class Project with _$Project {
  const Project._(); // Private constructor for custom methods

  @JsonSerializable(explicitToJson: true)
  const factory Project({
    required String id,
    required String userId,
    required String title,
    String? description,
    @LongDescriptionConverter() String? longDescription,
    required AppCategory category,
    required Environment environment,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(ignore: true) @Default(<Note>[]) List<Note> notes,
    @JsonKey(ignore: true) @Default(<Revision>[]) List<Revision> revisions,
    @JsonKey(ignore: true) @Default(<Todo>[]) List<Todo> todos,
    int? notesCount,
    int? todosCount,
    int? revisionsCount,
    int? completedTodosCount,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toCreatePayload() {
    return {
      'title': title,
      if (description != null && description!.trim().isNotEmpty)
        'description': description,
      'category': category.apiValue,
      'environment': environment.apiValue,
      'longDescription': const LongDescriptionConverter().toJson(
        longDescription,
      ),
    };
  }

  Map<String, dynamic> toUpdatePayload({bool includeLongDescription = false}) {
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category.apiValue,
      'environment': environment.apiValue,
    };

    payload.removeWhere((_, value) => value == null);

    if (includeLongDescription) {
      payload['longDescription'] = const LongDescriptionConverter().toJson(
        longDescription,
      );
    }

    return payload;
  }
}
