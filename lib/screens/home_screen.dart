import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/domain/academic/models/academic_year.dart';
import 'package:zypher/domain/academic/services/academic_service.service.repository.dart';
import 'package:zypher/domain/academic/usecases/get_active_period_usecase.dart';
import 'package:zypher/domain/enrollment/dtos/get_enrollments_by_guardian_dto.dart';
import 'package:zypher/domain/enrollment/services/enrollment_service_repository.dart';
import 'package:zypher/domain/enrollment/usecases/get_enrollments_by_guardian_usecase.dart';
import 'package:zypher/screens/dashboard_screen.dart';
import 'package:zypher/core/constants/dashboard_colors.dart';

import 'asistencias_screen.dart';
import 'observaciones_screen.dart';
import 'configuracion_screen.dart';
import 'package:provider/provider.dart';
import '../core/providers/student_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  AcademicYear? _activePeriod;
  final supabaseClient = Supabase.instance.client;

  final List<Widget> _screens = [
    DashboardScreen(),
    AsistenciasScreen(),
    ObservacionesScreen(),
    ObservacionesScreen(), // Placeholder para Eventos
    ConfiguracionScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchActivePeriod();
  }

  Future<void> _fetchActivePeriod() async {
    final activePeriod = await GetActivePeriodUseCase(
      AcademicPeriodServiceRepository(Supabase.instance.client),
    ).execute();
    if (activePeriod == null) return;
    if (mounted) {
      setState(() => _activePeriod = activePeriod);
      _fetchStudents(activePeriod);
    }
  }

  Future<void> _fetchStudents(AcademicYear activePeriod) async {
    final user = supabaseClient.auth.currentUser;
    final userEmail = user?.email ?? '';
    final enrollments = await GetEnrollmentsByGuardianUseCase(
      SupabaseEnrollmentRepository(supabaseClient),
    ).execute(
      GetEnrollmentsByGuardianDTO(
        academicPeriodId: activePeriod.id ?? '',
        email: userEmail,
      ),
    );
    if (mounted) {
      Provider.of<StudentProvider>(context, listen: false).setStudents(enrollments);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? DashboardColors.mainBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? DashboardColors.mainBackground : Colors.white,
        title: Text(
          'Zypher',
          style: TextStyle(
            color: isDark ? DashboardColors.primaryText : const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<StudentProvider>(
            builder: (context, studentProvider, _) {
              final currentStudent = studentProvider.currentStudent;
              if (currentStudent == null) return Container();
              final student = currentStudent.student;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                'Cambiar de estudiante',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(
                              studentProvider.students.length,
                              (i) {
                                final s = studentProvider.students[i].student;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: s.thumbnail != null ? NetworkImage(s.thumbnail!) : null,
                                    child: s.thumbnail == null
                                        ? Text(
                                            '${s.firstName.isNotEmpty ? s.firstName[0] : ''}${s.lastName.isNotEmpty ? s.lastName[0] : ''}',
                                            style: const TextStyle(color: Colors.white),
                                          )
                                        : null,
                                  ),
                                  title: Text('${s.firstName} ${s.lastName}'),
                                  selected: i == studentProvider.currentIndex,
                                  onTap: () {
                                    studentProvider.changeStudent(i);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: student.thumbnail != null ? NetworkImage(student.thumbnail!) : null,
                        child: student.thumbnail == null
                            ? Text(
                                '${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}',
                                style: TextStyle(
                                  color: DashboardColors.primaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DEBUG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: DashboardColors.accentBlue,
        unselectedItemColor: DashboardColors.tertiaryText,
        backgroundColor: isDark ? DashboardColors.mainBackground : Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Asistencia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
