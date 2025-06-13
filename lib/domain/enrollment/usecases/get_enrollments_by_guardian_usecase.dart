import '../repositories/enrollment_repository.dart';
import '../dtos/get_enrollments_by_guardian_dto.dart';
import '../models/enrollment.dart';

class GetEnrollmentsByGuardianUseCase {
  final EnrollmentRepository repository;

  GetEnrollmentsByGuardianUseCase(this.repository);

  Future<List<EnrollmentWithRelations>> execute(GetEnrollmentsByGuardianDTO params) async {
    return await repository.getEnrollmentsByGuardian(
      academicPeriodId: params.academicPeriodId,
      email: params.email,
    );
  }
}
