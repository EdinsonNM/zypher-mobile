import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/core/constants/tailwind_colors.dart';
import 'package:zypher/core/providers/student_provider.dart';
import 'package:zypher/domain/academic/models/academic_year.dart';
import 'package:zypher/domain/academic/services/academic_service.service.repository.dart';
import 'package:zypher/domain/academic/usecases/get_active_period_usecase.dart';
import 'package:zypher/domain/enrollment/models/enrollment.dart';
import 'package:zypher/domain/enrollment/models/enrollment_event.dart';
import 'package:zypher/domain/enrollment/services/enrollment_attendance_service_repository.dart';
import 'package:zypher/domain/enrollment/services/enrollment_obsevation_service_repository.dart';
import 'package:zypher/domain/enrollment/usecases/get_events_by_enrollment_and_date_usecase.dart';
import 'package:zypher/domain/enrollment/usecases/get_events_by_enrollment.usecase.dart';

class AsistenciasScreen extends StatefulWidget {
  const AsistenciasScreen({super.key});

  @override
  State<AsistenciasScreen> createState() => _AsistenciasScreenState();
}

class _AsistenciasScreenState extends State<AsistenciasScreen> {
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
    if (!mounted) return;
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
    if (!mounted) return;
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
