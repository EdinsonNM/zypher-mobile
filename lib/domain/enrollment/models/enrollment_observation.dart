import 'package:zypher/domain/enrollment/models/observation_category.dart';

class EnrollmentObservation {
  String? id;
  String enrollmentId;
  String categoryId;
  String title;
  String description;
  String severity;
  String status;
  DateTime? resolutionDate;
  String? resolutionNotes;
  String? createdBy;
  String? resolvedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime date;

  ObservationCategory? category;

  EnrollmentObservation({
    this.id,
    required this.enrollmentId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    this.resolutionDate,
    this.resolutionNotes,
    this.createdBy,
    this.resolvedBy,
    this.createdAt,
    this.updatedAt,
    required this.date,
    this.category,
  });

  factory EnrollmentObservation.fromJson(Map<String, dynamic> json) {
    return EnrollmentObservation(
      id: json['id'],
      enrollmentId: json['enrollment_id'],
      categoryId: json['category_id'],
      title: json['title'],
      description: json['description'],
      severity: json['severity'],
      status: "",
      resolutionDate:
          json['resolution_date'] != null
              ? DateTime.parse(json['resolution_date'])
              : null,
      resolutionNotes: json['resolution_notes'],
      createdBy: json['created_by'],
      resolvedBy: json['resolved_by'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      date: DateTime.parse(json['date']),
      category:
          json['observation_categories'] != null
              ? ObservationCategory.fromJson(json['observation_categories'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enrollment_id': enrollmentId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'severity': severity,
      'status': status,
      'resolution_date': resolutionDate?.toIso8601String(),
      'resolution_notes': resolutionNotes,
      'created_by': createdBy,
      'resolved_by': resolvedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'date': date.toIso8601String(),
      'category': category?.toJson(),
    };
  }
}
