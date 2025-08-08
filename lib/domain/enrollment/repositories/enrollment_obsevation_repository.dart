import 'package:zypher/domain/enrollment/models/enrollment_observation.dart';

abstract class EnrollmentObservationRepository {
  Future<List<EnrollmentObservation>> getObservationsByEnrollmentIdAndDate({
    required String enrollmentId,
    required DateTime date,
  });
  Future<List<EnrollmentObservation>> getObservationsByEnrollmentId({
    required String enrollmentId,
  });
}
