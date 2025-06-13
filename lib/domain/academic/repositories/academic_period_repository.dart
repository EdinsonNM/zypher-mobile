import '../models/academic_year.dart';

abstract class AcademicPeriodRepository {
  Future<AcademicYear?> getActivePeriod();
}
