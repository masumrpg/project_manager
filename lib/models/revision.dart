import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums/revision_status.dart';

part 'revision.freezed.dart';
part 'revision.g.dart';

class ChangesConverter implements JsonConverter<List<String>, dynamic> {
  const ChangesConverter();

  @override
  List<String> fromJson(dynamic json) {
     if (json is List) {
      return json.map((item) => item.toString()).toList();
    }
    if (json is String && json.isNotEmpty) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        // ignore
      }
      return json.split('\n');
    }
    return <String>[];
  }

  @override
  dynamic toJson(List<String> object) {
    return object;
  }
}

@freezed
class Revision with _$Revision {
  const Revision._();

  const factory Revision({
    required String id,
    required String projectId,
    required String version,
    required String description,
    @ChangesConverter() required List<String> changes,
    @Default(RevisionStatus.pending) RevisionStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Revision;

  factory Revision.fromJson(Map<String, dynamic> json) =>
      _$RevisionFromJson(json);

  Map<String, dynamic> toApiPayload() {
    return {
      'version': version,
      'description': description,
      'changes': changes,
      'status': status.apiValue,
    };
  }
}