import 'package:zypher/domain/enrollment/models/enrollment_attendance.dart';

abstract class EnrollmentAttendanceRepository {
  Future<List<EnrollmentAttendance>> getAttendanceByEnrollmentIdAndDate({
    required String enrollmentId,
    required DateTime date,
  });
}
