import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<Map<String, dynamic>?> fetchEnrollmentDetails(
      String enrollmentId) async {
    try {
      final response = await client.from('enrollments').select('''
            *,
            students (
              firstname, 
              lastname, 
              documentNumber, 
              documentType, 
              birthdate, 
              sex,
              phone
            ),
            grades (
              name,
              level
            ),
            academic_periods (
              name,
              year,
              startDate,
              endDate
            )
          ''').eq('id', enrollmentId).single();

      return response;
    } catch (e) {
      print('Error fetching enrollment: $e');
      return null;
    }
  }
}
