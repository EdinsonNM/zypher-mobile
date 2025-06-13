import 'package:zypher/domain/academic/models/academic_year.dart';
import 'package:zypher/domain/enrollment/models/grade.dart';
import 'package:zypher/domain/enrollment/models/student.dart';

class Enrollment {
  final String id;
  final String studentId;
  final String academicPeriodId;
  final String gradeId;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;

  Enrollment({
    required this.id,
    required this.studentId,
    required this.academicPeriodId,
    required this.gradeId,
    required this.status,
    required this.startDate,
    this.endDate,
  });

  // Método para convertir desde JSON
  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],
      studentId: json['student_id'],
      academicPeriodId: json['academic_period_id'],
      gradeId: json['grade_id'],
      status: json['status'],
      startDate: DateTime.parse(json['created_at']),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'academic_period_id': academicPeriodId,
      'grade_id': gradeId,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}

// Modelo para las relaciones
class EnrollmentWithRelations {
  final Enrollment enrollment;
  final Student student;
  final AcademicYear academicPeriod;
  final Grade grade;

  EnrollmentWithRelations({
    required this.enrollment,
    required this.student,
    required this.academicPeriod,
    required this.grade,
  });

  factory EnrollmentWithRelations.fromJson(Map<String, dynamic> json) {
    return EnrollmentWithRelations(
      enrollment: Enrollment.fromJson(json),
      student: Student.fromJson(json['student']),
      academicPeriod: AcademicYear.fromJson(json['academic_periods']),
      grade: Grade.fromJson(json['grades']),
    );
  }
}
