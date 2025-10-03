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
  List<String> changes;
  DateTime createdAt;
  DateTime updatedAt;
  RevisionStatus status;

  factory Revision.fromJson(Map<String, dynamic> json, {String? fallbackProjectId}) {
    return Revision(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? fallbackProjectId ?? '',
      version: json['version'] as String? ?? '',
      description: json['description'] as String? ?? '',
      changes: _parseChanges(json['changes']),
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
    List<String>? changes,
    DateTime? createdAt,
    DateTime? updatedAt,
    RevisionStatus? status,
  }) {
    return Revision(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      version: version ?? this.version,
      description: description ?? this.description,
      changes: changes ?? List<String>.from(this.changes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  static List<String> _parseChanges(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        // ignore
      }
      return value.split('\n');
    }
    return <String>[];
  }
}
