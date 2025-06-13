import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/domain/enrollment/models/enrollment_attendance.dart'
    show EnrollmentAttendance;
import 'package:zypher/domain/enrollment/repositories/enrollment_attendance_repository.dart';

class EnrollmentAttendanceServiceRepository
    implements EnrollmentAttendanceRepository {
  final SupabaseClient client;

  EnrollmentAttendanceServiceRepository(this.client);

  @override
  Future<List<EnrollmentAttendance>> getAttendanceByEnrollmentIdAndDate({
    required String enrollmentId,
    required DateTime date,
  }) async {
    final response = await client
        .from('enrollment_attendances')
        .select('*')
        .eq('enrollment_id', enrollmentId)
        .eq('date', date.toIso8601String());

    final attendances =
        (response as List)
            .map((enrollment) => EnrollmentAttendance.fromJson(enrollment))
            .toList();

    return attendances;
  }
}
