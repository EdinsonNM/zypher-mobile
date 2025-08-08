import 'package:zypher/domain/enrollment/models/enrollment_observation.dart';
import 'package:zypher/domain/enrollment/repositories/enrollment_obsevation_repository.dart';

class GetEventsByEnrollmentUseCase {
  final EnrollmentObservationRepository observationRepository;
  GetEventsByEnrollmentUseCase({
    required this.observationRepository,
  });

  Future<List<EnrollmentObservation>> execute({
    required String enrollmentId,
  }) async {
    final observations = await observationRepository.getObservationsByEnrollmentId(enrollmentId: enrollmentId);
    return observations;
  }
}