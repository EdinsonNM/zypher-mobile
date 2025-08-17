import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/domain/academic/models/academic_year.dart';
import 'package:zypher/domain/academic/services/academic_service.service.repository.dart';
import 'package:zypher/domain/academic/usecases/get_active_period_usecase.dart';
import 'package:zypher/domain/enrollment/dtos/get_enrollments_by_guardian_dto.dart';
import 'package:zypher/domain/enrollment/services/enrollment_service_repository.dart';
import 'package:zypher/domain/enrollment/usecases/get_enrollments_by_guardian_usecase.dart';
import 'package:zypher/screens/dashboard_screen.dart';
import 'package:zypher/core/constants/theme_colors.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(theme),
      appBar: AppBar(
        backgroundColor: ThemeColors.getCardBackground(theme),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zypher',
              style: TextStyle(
                color: ThemeColors.getPrimaryText(theme),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              _getScreenTitle(_selectedIndex),
              style: TextStyle(
                color: ThemeColors.getSecondaryText(theme),
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
                            Center(
                              child: Text(
                                'Cambiar de estudiante',
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColors.getPrimaryText(theme),
                                ),
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
                                  title: Text(
                                    '${s.firstName} ${s.lastName}',
                                    style: TextStyle(
                                      color: ThemeColors.getPrimaryText(theme),
                                    ),
                                  ),
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
                                  color: ThemeColors.getPrimaryText(theme),
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
      bottomNavigationBar: _buildBottomNavigation(theme),
    );
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    return Container(
      color: ThemeColors.getCardBackground(theme),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ThemeColors.getCardBorder(theme),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Inicio', _selectedIndex == 0, () => _onItemTapped(0), theme),
              _buildNavItem(Icons.check_circle, 'Asistencia', _selectedIndex == 1, () => _onItemTapped(1), theme),
              _buildNavItem(Icons.event, 'Eventos', _selectedIndex == 2, () => _onItemTapped(2), theme),
              _buildNavItem(Icons.visibility, 'Observac.', _selectedIndex == 3, () => _onItemTapped(3), theme),
              _buildNavItem(Icons.settings, 'Ajustes', _selectedIndex == 4, () => _onItemTapped(4), theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ThemeColors.getCardBorder(theme).withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive 
                  ? ThemeColors.accentBlue
                  : ThemeColors.getTertiaryText(theme),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive 
                    ? ThemeColors.accentBlue
                    : ThemeColors.getTertiaryText(theme)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
