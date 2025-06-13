import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/domain/academic/models/academic_year.dart';
import 'package:zypher/domain/enrollment/models/grade.dart';
import '../models/enrollment.dart';
import '../models/student.dart';
import '../repositories/enrollment_repository.dart';

class SupabaseEnrollmentRepository implements EnrollmentRepository {
  final SupabaseClient client;

  SupabaseEnrollmentRepository(SupabaseClient this.client);

  @override
  Future<List<EnrollmentWithRelations>> getEnrollmentsByGuardian({
    required String academicPeriodId,
    required String email,
  }) async {
    try {
      // 1. Obtener el ID del familiar
      final familyMemberResponse =
          await client
              .from('family_members')
              .select('id')
              .eq('email', email)
              .single();

      // 2. Obtener los IDs de estudiantes asociados
      final studentFamiliesResponse = await client
          .from('student_family')
          .select('student_id')
          .eq('family_member_id', familyMemberResponse['id']);

      final studentIds =
          studentFamiliesResponse
              .map<String>((sf) => sf['student_id'] as String)
              .toList();

      // 3. Obtener el periodo académico
      final academicPeriodResponse =
          await client
              .from('academic_periods')
              .select('*')
              .eq('id', academicPeriodId)
              .single();

      final academicPeriod = AcademicYear.fromJson(academicPeriodResponse);

      // 4. Obtener las matriculaciones
      final response = await client
          .from('enrollments')
          .select('''
            *,
            student:students(*),
            grade:grades!inner(*)
          ''')
          .eq('academic_period_id', academicPeriodId)
          .inFilter('student_id', studentIds);

      final enrollments =
          (response as List).map((enrollment) {
            final studentJson = enrollment['student'];
            final gradeJson = enrollment['grade'];
            final enrollmentModel = Enrollment.fromJson(enrollment);
            final studentModel =
                studentJson != null
                    ? Student.fromJson(studentJson)
                    : Student.empty();
            final gradeModel =
                gradeJson != null ? Grade.fromJson(gradeJson) : Grade.empty();
            return EnrollmentWithRelations(
              enrollment: enrollmentModel,
              student: studentModel,
              academicPeriod: academicPeriod,
              grade: gradeModel,
            );
          }).toList();

      return enrollments;
    } catch (e) {
      throw Exception('Error fetching enrollments: $e');
    }
  }

  // Implementar otros métodos del repository...
}
