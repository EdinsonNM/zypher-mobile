import 'package:zypher/domain/enrollment/models/enrollment.dart'
    show EnrollmentWithRelations;

abstract class EnrollmentRepository {
  Future<List<EnrollmentWithRelations>> getEnrollmentsByGuardian({
    required String academicPeriodId,
    required String email,
  });
}
