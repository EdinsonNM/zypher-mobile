import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:zypher/domain/academic/models/academic_year.dart';
import 'package:zypher/domain/academic/services/academic_service.service.repository.dart';
import 'package:zypher/domain/academic/usecases/get_active_period_usecase.dart';
import 'package:zypher/domain/enrollment/dtos/get_enrollments_by_guardian_dto.dart';
import 'package:zypher/domain/enrollment/models/enrollment_event.dart';
import 'package:zypher/domain/enrollment/services/enrollment_attendance_service_repository.dart';
import 'package:zypher/domain/enrollment/services/enrollment_obsevation_service_repository.dart';
import 'package:zypher/domain/enrollment/services/enrollment_service_repository.dart';
import 'package:zypher/domain/enrollment/usecases/get_enrollments_by_guardian_usecase.dart';
import 'package:zypher/domain/enrollment/usecases/get_enrollments_by_guardian_usecase.dart';
import 'package:zypher/domain/enrollment/usecases/get_events_by_enrollment_and_date_usecase.dart';

import '../domain/enrollment/models/enrollment.dart';
import 'package:zypher/core/constants/tailwind_colors.dart';
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
    HomeBody(),
    AsistenciasScreen(),
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
    setState(() => _activePeriod = activePeriod);
    _fetchStudents(activePeriod);
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
    Provider.of<StudentProvider>(context, listen: false).setStudents(enrollments);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<StudentProvider>(
          builder: (context, studentProvider, _) {
            final students = studentProvider.students;
            final current = studentProvider.currentIndex;
            return students.isEmpty
                ? const Text('Zypher')
                : DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: current,
                      items: List.generate(
                        students.length,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text('${students[i].student.firstName} ${students[i].student.lastName}'),
                        ),
                      ),
                      onChanged: (i) {
                        if (i != null) studentProvider.changeStudent(i);
                      },
                    ),
                  );
          },
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
                  child: CircleAvatar(
                    backgroundImage: student.thumbnail != null ? NetworkImage(student.thumbnail!) : null,
                    child: student.thumbnail == null
                        ? Text(
                            '${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
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
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Asistencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'Observaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}

class HomeBody extends StatefulWidget {
  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  DateTime _selectedDate = DateTime.now();
  List<EnrollmentEvent> _timelineItems = [];
  AcademicYear? _activePeriod;
  final supabaseClient = Supabase.instance.client;

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
    setState(() => _activePeriod = activePeriod);
    _fetchTimelineItems();
  }

  Future<void> _fetchTimelineItems() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final currentStudent = studentProvider.currentStudent;
    if (currentStudent == null) return;
    final events = await GetEventsByEnrollmentAndDateUseCase(
      observationRepository: EnrollmentObservationServiceRepository(
        supabaseClient,
      ),
      attendanceRepository: EnrollmentAttendanceServiceRepository(
        supabaseClient,
      ),
    ).execute(
      enrollmentId: currentStudent.enrollment.id,
      date: _selectedDate,
    );
    setState(() => _timelineItems = events);
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentStudent = studentProvider.currentStudent;
    return Column(
      children: [
        // Sección de bienvenida y año académico
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¡Bienvenido!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Año Académico - ${_activePeriod?.year ?? "2025"}',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (currentStudent != null) _buildStudentHeader(currentStudent, studentProvider),
                  const SizedBox(height: 16),
                  _buildWeeklyCalendar(),
                  const SizedBox(height: 16),
                  _buildTimeline(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentHeader(EnrollmentWithRelations studentEnrollment, StudentProvider studentProvider) {
    final student = studentEnrollment.student;
    final grade = studentEnrollment.grade;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: studentProvider.currentIndex > 0
              ? () => studentProvider.changeStudent(studentProvider.currentIndex - 1)
              : null,
        ),
        CircleAvatar(
          radius: 24,
          backgroundImage: student.thumbnail != null ? NetworkImage(student.thumbnail!) : null,
          child: student.thumbnail == null
              ? Text(
                  '${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${student.firstName} ${student.lastName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${grade.level.toString().split('.').last} / ${grade.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: studentProvider.currentIndex < studentProvider.students.length - 1
              ? () => studentProvider.changeStudent(studentProvider.currentIndex + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar() {
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMMM', 'es').format(weekDays.first),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed:
                          () => setState(() {
                            _selectedDate = _selectedDate.subtract(
                              const Duration(days: 7),
                            );
                          }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          () => setState(() {
                            _selectedDate = _selectedDate.add(
                              const Duration(days: 7),
                            );
                          }),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  weekDays.map((day) {
                    return InkWell(
                      onTap:
                          () => setState(() {
                            _selectedDate = day;
                            _fetchTimelineItems();
                          }),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              _selectedDate.day == day.day
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('EEE', 'es').format(day)[0],
                              style: TextStyle(
                                color:
                                    _selectedDate.day == day.day
                                        ? Colors.white
                                        : null,
                              ),
                            ),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                color:
                                    _selectedDate.day == day.day
                                        ? Colors.white
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Convierte un color de Tailwind a un color de Dart
  Color _getTailwindColor(String tailwindColor) {
    return TailwindColors.getTailwindColor(tailwindColor);
  }

  Widget _buildTimeline() {
    if (_timelineItems.isEmpty) {
      return const Center(child: Text('No hay eventos para mostrar'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          _timelineItems.map((EnrollmentEvent item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  item.type == 'attendance' && item.title == 'Asistió'
                      ? Icons.check_circle
                      : Icons.error,
                  color: _getTailwindColor(item.color),
                ),
                title: Text(item.title),
                subtitle: Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(DateFormat('hh:mm a').format(item.date)),
              ),
            );
          }).toList(),
    );
  }
}
