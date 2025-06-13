import 'package:zypher/domain/enrollment/enums/enrollment_attendance_status.dart'
    show EnrollmentAttendanceStatus;
import 'package:zypher/domain/enrollment/enums/enrollment_attendance_status.dart';
import 'package:zypher/domain/enrollment/models/enrollment_attendance.dart';
import 'package:zypher/domain/enrollment/models/enrollment_event.dart';
import 'package:zypher/domain/enrollment/repositories/enrollment_obsevation_repository.dart';
import 'package:zypher/domain/enrollment/repositories/enrollment_attendance_repository.dart';
import 'package:zypher/domain/enrollment/models/enrollment_observation.dart';

class GetEventsByEnrollmentAndDateUseCase {
  final EnrollmentObservationRepository observationRepository;
  final EnrollmentAttendanceRepository attendanceRepository;
  GetEventsByEnrollmentAndDateUseCase({
    required this.observationRepository,
    required this.attendanceRepository,
  });

  Future<List<EnrollmentEvent>> execute({
    required String enrollmentId,
    required DateTime date,
  }) async {
    final events = <EnrollmentEvent>[];
    final attendances = await attendanceRepository
        .getAttendanceByEnrollmentIdAndDate(
          enrollmentId: enrollmentId,
          date: date,
        );
    if (attendances.isNotEmpty) {
      events.add(EnrollmentEvent.fromAttendance(attendances.first));
    } else {
      events.add(
        EnrollmentEvent.fromAttendance(
          EnrollmentAttendance(
            id: '0',
            enrollmentId: enrollmentId,
            date: date,
            status: EnrollmentAttendanceStatus.absent.name,
          ),
        ),
      );
    }
    final observations = await observationRepository
        .getObservationsByEnrollmentIdAndDate(
          enrollmentId: enrollmentId,
          date: date,
        );
    events.addAll(observations.map(EnrollmentEvent.fromObservation));
    return events;
  }
}
