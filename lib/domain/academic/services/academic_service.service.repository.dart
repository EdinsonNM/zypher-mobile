import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/academic_year.dart';
import '../repositories/academic_period_repository.dart';

class AcademicPeriodServiceRepository implements AcademicPeriodRepository {
  final SupabaseClient client;

  AcademicPeriodServiceRepository(this.client);

  @override
  Future<AcademicYear?> getActivePeriod() async {
    try {
      final response =
          await client
              .from('academic_periods')
              .select()
              .eq('is_active', true)
              .single();

      return response != null ? AcademicYear.fromJson(response) : null;
    } catch (e) {
      throw Exception('Error fetching active period: $e');
    }
  }
}
