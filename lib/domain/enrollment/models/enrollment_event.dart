import 'package:zypher/domain/enrollment/enums/enrollment_attendance_status.dart';
import 'package:zypher/domain/enrollment/models/enrollment_attendance.dart';
import 'package:zypher/domain/enrollment/models/enrollment_observation.dart';

class EnrollmentEvent {
  final String id;
  final String type;
  final DateTime date;
  final String title;
  final String color;
  final String description;
  final String colorEvent;

  EnrollmentEvent({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.color,
    required this.description,
    required this.colorEvent,
  });

  factory EnrollmentEvent.fromAttendance(EnrollmentAttendance record) {
    return EnrollmentEvent(
      id: record.id!,
      type: "attendance",
      date: record.createdAt ?? record.date,
      title:
          record.status == EnrollmentAttendanceStatus.present.name
              ? "Asistió"
              : "No asistió",
      color:
          record.status == EnrollmentAttendanceStatus.present.name
              ? "bg-emerald-100"
              : "bg-red-100",
      description: record.observations ?? "",
      colorEvent: "white",
    );
  }

  factory EnrollmentEvent.fromObservation(EnrollmentObservation record) {
    return EnrollmentEvent(
      id: record.id!,
      type: "observation",
      date: record.date,
      title: record.title,
      color: record.category?.color ?? "",
      description: record.description,
      colorEvent: record.category?.color ?? "",
    );
  }
}
