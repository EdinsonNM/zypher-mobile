import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/domain/enrollment/models/enrollment_observation.dart'
    show EnrollmentObservation;
import 'package:zypher/domain/enrollment/repositories/enrollment_obsevation_repository.dart';

class EnrollmentObservationServiceRepository
    implements EnrollmentObservationRepository {
  final SupabaseClient client;

  EnrollmentObservationServiceRepository(this.client);

  @override
  Future<List<EnrollmentObservation>> getObservationsByEnrollmentIdAndDate({
    required String enrollmentId,
    required DateTime date,
  }) async {
    final response = await client
        .from('enrollment_observations')
        .select('*, observation_categories(*)')
        .eq('enrollment_id', enrollmentId)
        .eq('date', date.toIso8601String());

    final observations =
        (response as List)
            .map((obs) => EnrollmentObservation.fromJson(obs))
            .toList();

    return observations;
  }

  @override
  Future<List<EnrollmentObservation>> getObservationsByEnrollmentId({
    required String enrollmentId,
  }) async {
    final response = await client.from('enrollment_observations').select('*').eq('enrollment_id', enrollmentId);
    return response.map((e) => EnrollmentObservation.fromJson(e)).toList();
  }
}
