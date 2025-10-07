import 'dart:convert';

import 'enums/revision_status.dart';

class Revision {
  Revision({
    required this.id,
    required this.projectId,
    required this.version,
    required this.description,
    required this.changes,
    this.status = RevisionStatus.pending,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  String id;
  String projectId;
  String version;
  String description;
  String changes;
  DateTime createdAt;
  DateTime updatedAt;
  RevisionStatus status;

  factory Revision.fromJson(Map<String, dynamic> json, {String? fallbackProjectId}) {
    return Revision(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? fallbackProjectId ?? '',
      version: json['version'] as String? ?? '',
      description: json['description'] as String? ?? '',
      changes: _parseChangesFromJson(json['changes']),
      status: RevisionStatusX.fromApiValue(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toApiPayload() {
    return {
      'version': version,
      'description': description,
      'changes': changes,
      'status': status.apiValue,
    };
  }

  Revision copyWith({
    String? id,
    String? projectId,
    String? version,
    String? description,
    String? changes,
    DateTime? createdAt,
    DateTime? updatedAt,
    RevisionStatus? status,
  }) {
    return Revision(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      version: version ?? this.version,
      description: description ?? this.description,
      changes: changes ?? this.changes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  static String _parseChangesFromJson(dynamic changesValue) {
    if (changesValue == null) {
      return '';
    }
    // If it's already a string, it's the new JSON delta format (or a plain text from even older data).
    if (changesValue is String) {
      return changesValue;
    }
    // If it's a list, it's likely a pre-parsed JSON array from the API (a Quill delta).
    if (changesValue is List) {
      // We need to convert this List<dynamic> (which is a delta) back into a JSON string.
      return jsonEncode(changesValue);
    }
    // Fallback for other unexpected types.
    return '';
  }
}
