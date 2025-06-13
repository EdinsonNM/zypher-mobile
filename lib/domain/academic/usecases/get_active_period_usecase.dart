import '../repositories/academic_period_repository.dart';
import '../models/academic_year.dart';

class GetActivePeriodUseCase {
  final AcademicPeriodRepository repository;

  GetActivePeriodUseCase(this.repository);

  Future<AcademicYear?> execute() async {
    return await repository.getActivePeriod();
  }
}
