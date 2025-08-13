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
  DateTime _selectedWeekStart = DateTime.now();
  List<EnrollmentEvent> _weeklyEvents = [];
  AcademicYear? _activePeriod;
  final supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = _getWeekStart(_selectedDate);
    _fetchActivePeriod();
  }

  DateTime _getWeekStart(DateTime date) {
    // Calcular el inicio de semana desde el domingo (weekday 7 = domingo, 1 = lunes)
    // Si es domingo (weekday = 7), no restar días
    // Si es lunes (weekday = 1), restar 1 día para llegar al domingo
    // Si es martes (weekday = 2), restar 2 días para llegar al domingo, etc.
    final daysToSubtract = date.weekday == 7 ? 0 : date.weekday;
    return date.subtract(Duration(days: daysToSubtract));
  }

  Future<void> _fetchActivePeriod() async {
    final activePeriod = await GetActivePeriodUseCase(
      AcademicPeriodServiceRepository(Supabase.instance.client),
    ).execute();
    if (activePeriod == null) return;
    if (mounted) {
      setState(() => _activePeriod = activePeriod);
      _fetchWeeklyEvents();
    }
  }

  Future<void> _fetchWeeklyEvents() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final currentStudent = studentProvider.currentStudent;
    if (currentStudent == null) return;

    // Obtener eventos para toda la semana
    List<EnrollmentEvent> allWeeklyEvents = [];
    
    for (int i = 0; i < 7; i++) {
      final dayDate = _selectedWeekStart.add(Duration(days: i));
      final events = await GetEventsByEnrollmentAndDateUseCase(
        observationRepository: EnrollmentObservationServiceRepository(
          supabaseClient,
        ),
        attendanceRepository: EnrollmentAttendanceServiceRepository(
          supabaseClient,
        ),
      ).execute(
        enrollmentId: currentStudent.enrollment.id,
        date: dayDate,
      );
      allWeeklyEvents.addAll(events);
    }

    if (mounted) {
      setState(() => _weeklyEvents = allWeeklyEvents);
    }
  }

  void _navigateWeek(int direction) {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(Duration(days: 7 * direction));
      _selectedDate = _selectedWeekStart.add(Duration(days: _selectedDate.weekday - 1));
    });
    _fetchWeeklyEvents();
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
                  _buildWeeklyTimeline(),
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
    final weekDays = List.generate(7, (i) => _selectedWeekStart.add(Duration(days: i)));
    final weekEnd = _selectedWeekStart.add(const Duration(days: 6));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${DateFormat('d MMM', 'es').format(_selectedWeekStart)} - ${DateFormat('d MMM', 'es').format(weekEnd)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _navigateWeek(-1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _navigateWeek(1),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((day) {
                final isSelected = _selectedDate.day == day.day && 
                                 _selectedDate.month == day.month && 
                                 _selectedDate.year == day.year;
                final hasEvents = _weeklyEvents.any((event) => 
                  event.date.day == day.day && 
                  event.date.month == day.month && 
                  event.date.year == day.year
                );
                
                return InkWell(
                  onTap: () => setState(() {
                    _selectedDate = day;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: hasEvents ? Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        width: 1,
                      ) : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEE', 'es').format(day)[0],
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: hasEvents ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: hasEvents ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildWeeklyTimeline() {
    // Filtrar eventos solo para la semana seleccionada
    final weekEvents = _weeklyEvents.where((event) {
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      final weekStart = _selectedWeekStart;
      final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
      return eventDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
             eventDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    // Ordenar eventos por fecha y hora
    weekEvents.sort((a, b) => a.date.compareTo(b.date));

    if (weekEvents.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.event_note,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'No hay eventos esta semana',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Historial de la semana',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...weekEvents.map((EnrollmentEvent item) {
          final isToday = DateTime.now().day == item.date.day && 
                         DateTime.now().month == item.date.month && 
                         DateTime.now().year == item.date.year;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTailwindColor(item.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.type == 'attendance' && item.title == 'Asistió'
                      ? Icons.check_circle
                      : Icons.error,
                  color: _getTailwindColor(item.color),
                  size: 20,
                ),
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('EEEE, d MMM', 'es').format(item.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(item.date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isToday ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'HOY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
