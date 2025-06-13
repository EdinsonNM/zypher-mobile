import 'package:zypher/domain/enrollment/models/enrollment_observation.dart';

abstract class EnrollmentObservationRepository {
  Future<List<EnrollmentObservation>> getObservationsByEnrollmentIdAndDate({
    required String enrollmentId,
    required DateTime date,
  });
}
