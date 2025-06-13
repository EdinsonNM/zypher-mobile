class EnrollmentAttendance {
  String? id;
  String enrollmentId;
  DateTime date;
  String status;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  String? observations;
  bool hasObservations;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? createdBy;
  String? updatedBy;

  EnrollmentAttendance({
    this.id,
    required this.enrollmentId,
    required this.date,
    this.status = '',
    this.checkInTime,
    this.checkOutTime,
    this.observations,
    this.hasObservations = false,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory EnrollmentAttendance.fromJson(Map<String, dynamic> json) {
    return EnrollmentAttendance(
      id: json['id'],
      enrollmentId: json['enrollment_id'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      checkInTime:
          json['check_in_time'] != null
              ? DateTime.parse(json['check_in_time'])
              : null,
      checkOutTime:
          json['check_out_time'] != null
              ? DateTime.parse(json['check_out_time'])
              : null,
      observations: json['observations'],
      hasObservations: json['has_observations'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'enrollment_id': enrollmentId,
    'date': date.toIso8601String(),
    'status': status,
    'check_in_time': checkInTime?.toIso8601String(),
    'check_out_time': checkOutTime?.toIso8601String(),
    'observations': observations,
    'has_observations': hasObservations,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'created_by': createdBy,
    'updated_by': updatedBy,
  };
}
