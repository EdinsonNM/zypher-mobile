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
import 'eventos_screen.dart';
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
    EventosScreen(),
    ObservacionesScreen(),
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
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Asistencia';
      case 2:
        return 'Eventos';
      case 3:
        return 'Observaciones';
      case 4:
        return 'Ajustes';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? DashboardColors.mainBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zypher',
              style: TextStyle(
                color: isDark ? DashboardColors.primaryText : const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              _getScreenTitle(_selectedIndex),
              style: TextStyle(
                color: isDark ? DashboardColors.secondaryText : const Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
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
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      color: const Color(0xFF1F2937), // bg-gray-800
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color(0xFF374151), // border-gray-700
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Inicio', _selectedIndex == 0, () => _onItemTapped(0)),
              _buildNavItem(Icons.check_circle, 'Asistencia', _selectedIndex == 1, () => _onItemTapped(1)),
              _buildNavItem(Icons.event, 'Eventos', _selectedIndex == 2, () => _onItemTapped(2)),
              _buildNavItem(Icons.visibility, 'Observac.', _selectedIndex == 3, () => _onItemTapped(3)),
              _buildNavItem(Icons.settings, 'Ajustes', _selectedIndex == 4, () => _onItemTapped(4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF374151).withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive 
                  ? const Color(0xFF60A5FA) // text-blue-400
                  : const Color(0xFF9CA3AF), // text-gray-400
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive 
                    ? const Color(0xFF60A5FA) // text-blue-400
                    : const Color(0xFF9CA3AF) // text-gray-400
              ),
            ),
          ],
        ),
      ),
    );
  }
}
