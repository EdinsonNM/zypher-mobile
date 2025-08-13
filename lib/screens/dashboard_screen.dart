import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:zypher/domain/academic/models/academic_year.dart';
import 'package:zypher/domain/academic/services/academic_service.service.repository.dart';
import 'package:zypher/domain/academic/usecases/get_active_period_usecase.dart';
import 'package:zypher/domain/enrollment/models/enrollment_event.dart';
import 'package:zypher/domain/enrollment/services/enrollment_attendance_service_repository.dart';
import 'package:zypher/domain/enrollment/services/enrollment_obsevation_service_repository.dart';
import 'package:zypher/domain/enrollment/usecases/get_events_by_enrollment_and_date_usecase.dart';

import '../domain/enrollment/models/enrollment.dart';
import 'package:zypher/core/constants/tailwind_colors.dart';
import 'package:zypher/core/constants/dashboard_colors.dart';
import 'package:provider/provider.dart';
import '../core/providers/student_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard/components/student_header.dart';
import 'dashboard/components/arrival_history_chart.dart';
import 'dashboard/components/observations_card.dart';
import 'dashboard/components/notifications_card.dart';
import 'dashboard/components/upcoming_events_card.dart';
import 'dashboard/components/pending_payments_card.dart';
import 'dashboard/components/dashboard_modals.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  List<EnrollmentEvent> _timelineItems = [];
  AcademicYear? _activePeriod;
  
  // Variables para estadísticas relevantes para padres
  int _recentObservations = 0;
  int _upcomingParentEvents = 0;
  int _pendingPayments = 0;
  bool _isLoadingStats = false;
  
  // Datos reales del dashboard
  List<Map<String, String>> _observations = [];
  List<Map<String, String>> _notifications = [];
  List<Map<String, String>> _upcomingEvents = [];
  List<Map<String, String>> _pendingPaymentsList = [];
  
  final supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    print('=== DashboardScreen initState ===');
    _fetchActivePeriod();
  }

  Future<void> _fetchActivePeriod() async {
    print('=== _fetchActivePeriod started ===');
    final activePeriod = await GetActivePeriodUseCase(
      AcademicPeriodServiceRepository(Supabase.instance.client),
    ).execute();
    
    print('Active period result: ${activePeriod?.name}');
    
    if (activePeriod == null) {
      print('No active period found, returning early');
      return;
    }
    
    if (mounted) {
      setState(() => _activePeriod = activePeriod);
      print('Active period set, calling _fetchTimelineItems and _fetchAllStats');
      _fetchTimelineItems();
      _fetchAllStats();
    }
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
    if (mounted) {
      setState(() => _timelineItems = events);
    }
  }

  Future<void> _fetchAllStats() async {
    print('=== STARTING _fetchAllStats ===');
    
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final currentStudent = studentProvider.currentStudent;
    
    print('Student provider found: ${studentProvider != null}');
    print('Current student: ${currentStudent?.enrollment.id}');
    print('Active period: ${_activePeriod?.name}');
    
    if (currentStudent == null || _activePeriod == null) {
      print('Early return: currentStudent=${currentStudent != null}, _activePeriod=${_activePeriod != null}');
      return;
    }

    if (mounted) {
      setState(() => _isLoadingStats = true);
    }

    try {
      final startDate = _activePeriod!.startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final endDate = _activePeriod!.endDate ?? DateTime.now();
      
      print('Date range: $startDate to $endDate');
      print('Starting parallel execution...');
      
      // Ejecutar todas las consultas en paralelo
      await Future.wait([
        _fetchRecentObservations(currentStudent.enrollment.id, startDate, endDate),
        _fetchUpcomingParentEvents(currentStudent.enrollment.id),
        _fetchPendingPayments(currentStudent.enrollment.id),
        _fetchObservationsData(currentStudent.enrollment.id, startDate, endDate),
        _fetchNotificationsData(currentStudent.enrollment.id),
        _fetchUpcomingEventsData(currentStudent.enrollment.id),
        _fetchPendingPaymentsData(currentStudent.enrollment.id),
      ]);

      print('All functions completed successfully!');
      print('Final stats:');
      print('- Recent observations: $_recentObservations');
      print('- Upcoming parent events: $_upcomingParentEvents');
      print('- Pending payments: $_pendingPayments');
      print('- Observations data: ${_observations.length}');
      print('- Notifications data: ${_notifications.length}');
      print('- Upcoming events data: ${_upcomingEvents.length}');
      print('- Pending payments data: ${_pendingPaymentsList.length}');

      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      print('Error in _fetchAllStats: $e');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _fetchRecentObservations(String enrollmentId, DateTime startDate, DateTime endDate) async {
    print('>>> _fetchRecentObservations started');
    try {
      // Contar observaciones recientes (últimos 30 días)
      final response = await supabaseClient
          .from('enrollment_observations')
          .select('id, severity, title')
          .eq('enrollment_id', enrollmentId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('created_at', ascending: false);

      print('>>> _fetchRecentObservations: Found ${response.length} observations');

      if (mounted) {
        setState(() => _recentObservations = response.length);
      }
    } catch (e) {
      print('Error fetching recent observations: $e');
      if (mounted) {
        setState(() => _recentObservations = 0);
      }
    }
  }

  Future<void> _fetchUpcomingParentEvents(String enrollmentId) async {
    print('>>> _fetchUpcomingParentEvents started');
    try {
      // Buscar eventos de escuela de padres próximos
      final now = DateTime.now();
      final response = await supabaseClient
          .from('parent_school_events')
          .select('id, name, event_date, status')
          //.gte('event_date', now.toIso8601String())
          //.eq('status', 'scheduled')
          .order('event_date', ascending: true)
          .limit(5);

      print('>>> _fetchUpcomingParentEvents: Found ${response.length} events');

      if (mounted) {
        setState(() => _upcomingParentEvents = response.length);
      }
    } catch (e) {
      print('Error fetching upcoming parent events: $e');
      if (mounted) {
        setState(() => _upcomingParentEvents = 0);
      }
    }
  }

  Future<void> _fetchPendingPayments(String enrollmentId) async {
    try {
      // Obtener el período académico activo
      if (_activePeriod == null) {
        if (mounted) {
          setState(() => _pendingPayments = 0);
        }
        return;
      }

      final startDate = _activePeriod!.startDate ?? DateTime.now();
      final endDate = _activePeriod!.endDate ?? DateTime.now();
      final now = DateTime.now();

      // 1. Verificar si se pagó la matrícula
      final matriculaResponse = await supabaseClient
          .from('enrollment_payments')
          .select('id')
          .eq('enrollment_id', enrollmentId)
          .eq('payment_concept_id', '28e0de26-0beb-471d-bd9b-7f905fcda485') // ID de Matrícula
          .gte('payment_date', startDate.toIso8601String().split('T')[0])
          .lte('payment_date', endDate.toIso8601String().split('T')[0]);

      final matriculaPagada = matriculaResponse.isNotEmpty;

      // 2. Calcular mensualidades pendientes
      // Contar meses desde el inicio del período hasta el mes actual
      final startYear = startDate.year;
      final startMonth = startDate.month;
      final currentYear = now.year;
      final currentMonth = now.month;

      // Calcular el número total de meses del período
      final endYear = endDate.year;
      final endMonth = endDate.month;
      final totalMonths = (endYear - startYear) * 12 + (endMonth - startMonth) + 1;

      // Calcular hasta qué mes debería haber pagado (mes actual o fin del período)
      final monthsToPay = (currentYear - startYear) * 12 + (currentMonth - startMonth) + 1;
      final monthsToPayAdjusted = monthsToPay > totalMonths ? totalMonths : monthsToPay;

      // Verificar mensualidades pagadas
      final mensualidadesResponse = await supabaseClient
          .from('enrollment_payments')
          .select('id, payment_date')
          .eq('enrollment_id', enrollmentId)
          .eq('payment_concept_id', 'c224fd83-3aad-49d4-b622-4cac4f4e450d') // ID de Mensualidad
          .gte('payment_date', startDate.toIso8601String().split('T')[0])
          .lte('payment_date', endDate.toIso8601String().split('T')[0]);

      final mensualidadesPagadas = mensualidadesResponse.length;

      // Calcular pagos pendientes
      int pagosPendientes = 0;

      // Si no pagó matrícula, agregar 1
      if (!matriculaPagada) {
        pagosPendientes += 1;
      }

      // Agregar mensualidades pendientes
      final mensualidadesPendientes = monthsToPayAdjusted - mensualidadesPagadas;
      if (mensualidadesPendientes > 0) {
        pagosPendientes += mensualidadesPendientes;
      }

      if (mounted) {
        setState(() => _pendingPayments = pagosPendientes);
      }
    } catch (e) {
      print('Error fetching pending payments: $e');
      if (mounted) {
        setState(() => _pendingPayments = 0);
      }
    }
  }

  // Nuevas funciones para obtener datos reales
  Future<void> _fetchObservationsData(String enrollmentId, DateTime startDate, DateTime endDate) async {
    print('>>> _fetchObservationsData started');
    try {
      final response = await supabaseClient
          .from('enrollment_observations')
          .select('''
            title,
            description,
            severity,
            date,
            observation_categories(name)
          ''')
          .eq('enrollment_id', enrollmentId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('created_at', ascending: false)
          .limit(3);

      print('>>> _fetchObservationsData: Found ${response.length} observations');

      if (mounted) {
        setState(() {
          _observations = response.map((obs) => {
            'text': obs['title']?.toString() ?? 'Sin título',
            'teacher': obs['observation_categories']?['name']?.toString() ?? 'Sin categoría',
            'severity': obs['severity']?.toString() ?? 'low',
            'description': obs['description']?.toString() ?? '',
            'date': obs['date']?.toString() ?? '',
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching observations data: $e');
      if (mounted) {
        setState(() => _observations = []);
      }
    }
  }

  Future<void> _fetchNotificationsData(String enrollmentId) async {
    print('>>> _fetchNotificationsData started');
    try {
      // Obtener el grado del estudiante para filtrar notificaciones
      final enrollmentResponse = await supabaseClient
          .from('enrollments')
          .select('grade_id')
          .eq('id', enrollmentId)
          .single();
      
      final gradeId = enrollmentResponse['grade_id'];
      print('>>> _fetchNotificationsData: Grade ID: $gradeId');
      
      final response = await supabaseClient
          .from('notifications')
          .select('title, content, created_at, type, grade_ids')
          .eq('is_active', true)
          .eq('status', 'created')
          .or('type.eq.GENERAL,type.eq.BY_GRADE')
          .order('created_at', ascending: false)
          .limit(5);

      print('>>> _fetchNotificationsData: Found ${response.length} total notifications');
      
      if (mounted) {
        setState(() {
          _notifications = response.where((notif) {
            // Filtrar notificaciones generales o específicas del grado
            if (notif['type'] == 'GENERAL') return true;
            if (notif['type'] == 'BY_GRADE') {
              final gradeIds = notif['grade_ids'] as List?;
              return gradeIds?.contains(gradeId) ?? false;
            }
            return false;
          }).take(3).map((notif) {
            final createdAt = DateTime.parse(notif['created_at']);
            final now = DateTime.now();
            final difference = now.difference(createdAt);
            
            String timeAgo;
            if (difference.inHours < 1) {
              timeAgo = 'Hace ${difference.inMinutes} minutos';
            } else if (difference.inHours < 24) {
              timeAgo = 'Hace ${difference.inHours} horas';
            } else {
              timeAgo = 'Hace ${difference.inDays} días';
            }

            return {
              'text': notif['title']?.toString() ?? 'Sin título',
              'time': timeAgo,
              'content': notif['content']?.toString() ?? '',
              'isViewed': 'false',
            };
          }).toList();
        });
        
        print('>>> _fetchNotificationsData: Final notifications: ${_notifications.length}');
      }
    } catch (e) {
      print('Error fetching notifications data: $e');
      if (mounted) {
        setState(() => _notifications = []);
      }
    }
  }

  Future<void> _fetchUpcomingEventsData(String enrollmentId) async {
    print('>>> _fetchUpcomingEventsData started');
    try {
      print('Fetching upcoming events for enrollment: $enrollmentId');
      
      // Obtener el período académico del enrollment actual
      final enrollmentResponse = await supabaseClient
          .from('enrollments')
          .select('academic_period_id')
          .eq('id', enrollmentId)
          .single();
      
      final academicPeriodId = enrollmentResponse['academic_period_id'];
      print('>>> _fetchUpcomingEventsData: Academic period ID: $academicPeriodId');
      
      // Obtener eventos del período académico del estudiante
      final response = await supabaseClient
          .from('parent_school_events')
          .select('name, event_date, location, description')
          .eq('academic_period_id', academicPeriodId)
          .eq('status', 'scheduled')
          .order('event_date', ascending: true)
          .limit(3);

      print('>>> _fetchUpcomingEventsData: Found ${response.length} events for academic period $academicPeriodId');
      for (var event in response) {
        print('Event: ${event['name']} - Date: ${event['event_date']}');
      }
      
      if (mounted) {
        setState(() {
          _upcomingEvents = response.map((event) {
            final eventDate = DateTime.parse(event['event_date']);
            final formattedDate = DateFormat('dd \'de\' MMMM', 'es').format(eventDate);
            
            return {
              'text': event['name']?.toString() ?? 'Sin nombre',
              'date': formattedDate,
              'location': event['location']?.toString() ?? 'Sin ubicación',
              'description': event['description']?.toString() ?? '',
            };
          }).toList();
        });
        
        print('>>> _fetchUpcomingEventsData: Final events: ${_upcomingEvents.length}');
      }
    } catch (e) {
      print('Error fetching upcoming events data: $e');
      if (mounted) {
        setState(() => _upcomingEvents = []);
      }
    }
  }

  Future<void> _fetchPendingPaymentsData(String enrollmentId) async {
    print('>>> _fetchPendingPaymentsData started');
    try {
      if (_activePeriod == null) {
        print('>>> _fetchPendingPaymentsData: No active period');
        if (mounted) {
          setState(() => _pendingPaymentsList = []);
        }
        return;
      }

      final startDate = _activePeriod!.startDate ?? DateTime.now();
      final endDate = _activePeriod!.endDate ?? DateTime.now();
      final now = DateTime.now();
      
      print('>>> _fetchPendingPaymentsData: Period dates: $startDate to $endDate');

      // Obtener mensualidades pendientes
      final pendingMonths = <Map<String, String>>[];
      
      // Verificar matrícula
      final matriculaResponse = await supabaseClient
          .from('enrollment_payments')
          .select('id')
          .eq('enrollment_id', enrollmentId)
          .eq('payment_concept_id', '28e0de26-0beb-471d-bd9b-7f905fcda485')
          .gte('payment_date', startDate.toIso8601String().split('T')[0])
          .lte('payment_date', endDate.toIso8601String().split('T')[0]);

      print('>>> _fetchPendingPaymentsData: Matricula payments found: ${matriculaResponse.length}');

      if (matriculaResponse.isEmpty) {
        pendingMonths.add({
          'concept': 'Matrícula',
          'dueDate': 'Pendiente de pago',
          'amount': 'Por definir',
        });
      }

      // Verificar mensualidades
      final mensualidadesResponse = await supabaseClient
          .from('enrollment_payments')
          .select('billing_period')
          .eq('enrollment_id', enrollmentId)
          .eq('payment_concept_id', 'c224fd83-3aad-49d4-b622-4cac4f4e450d')
          .gte('billing_period', startDate.toIso8601String().split('T')[0])
          .lte('billing_period', endDate.toIso8601String().split('T')[0]);

      print('>>> _fetchPendingPaymentsData: Mensualidades payments found: ${mensualidadesResponse.length}');

      final paidMonths = mensualidadesResponse.map((p) => DateTime.parse(p['billing_period'])).toList();
      
      // Calcular meses pendientes
      DateTime currentMonth = DateTime(now.year, now.month, 1);
      DateTime periodStart = DateTime(startDate.year, startDate.month, 1);
      DateTime periodEnd = DateTime(endDate.year, endDate.month, 1);

      while (currentMonth.isBefore(periodEnd) || currentMonth.isAtSameMomentAs(periodEnd)) {
        if (currentMonth.isAfter(periodStart) || currentMonth.isAtSameMomentAs(periodStart)) {
          bool isPaid = paidMonths.any((paid) => 
            paid.year == currentMonth.year && paid.month == currentMonth.month);
          
          if (!isPaid) {
            final monthName = DateFormat('MMMM', 'es').format(currentMonth);
            pendingMonths.add({
              'concept': 'Pensión de $monthName',
              'dueDate': 'Pendiente de pago',
              'amount': 'Por definir',
            });
          }
        }
        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      }

      print('>>> _fetchPendingPaymentsData: Total pending months: ${pendingMonths.length}');

      if (mounted) {
        setState(() => _pendingPaymentsList = pendingMonths.take(3).toList());
        print('>>> _fetchPendingPaymentsData: Final pending payments: ${_pendingPaymentsList.length}');
      }
    } catch (e) {
      print('Error fetching pending payments data: $e');
      if (mounted) {
        setState(() => _pendingPaymentsList = []);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentStudent = studentProvider.currentStudent;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    print('=== DashboardScreen build ===');
    print('Current student in build: ${currentStudent?.enrollment.id}');
    print('Active period in build: ${_activePeriod?.name}');
    print('Is loading stats: $_isLoadingStats');
    
    // Si tenemos el estudiante pero no hemos cargado las estadísticas, cargarlas
    if (currentStudent != null && _activePeriod != null && !_isLoadingStats && _observations.isEmpty) {
      print('Triggering stats fetch from build...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAllStats();
      });
    }

    return Scaffold(
      backgroundColor: DashboardColors.mainBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentStudent != null)
                  StudentHeader(
                    studentEnrollment: currentStudent,
                    studentProvider: studentProvider,
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Historial de Llegada',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ver todo el historial')),
                        );
                      },
                      child: Text(
                        'Ver todo',
                        style: TextStyle(
                          fontSize: 14,
                          color: DashboardColors.accentBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ArrivalHistoryChart(enrollmentId: currentStudent?.enrollment.id),
                const SizedBox(height: 32),
                UpcomingEventsCard(
                  events: _upcomingEvents.isNotEmpty ? _upcomingEvents : [
                    {'text': 'No hay eventos próximos', 'date': 'Por el momento'},
                  ],
                  onViewAll: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ver todos los eventos')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                NotificationsCard(
                  notifications: _notifications.isNotEmpty ? _notifications : [
                    {'text': 'No hay notificaciones', 'time': 'Por el momento'},
                  ],
                  onViewAll: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ver todas las notificaciones')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                PendingPaymentsCard(
                  payments: _pendingPaymentsList.isNotEmpty ? _pendingPaymentsList : [
                    {'concept': 'No hay pagos pendientes', 'dueDate': 'Todo al día'},
                  ],
                  onGoToPay: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ir a pagar')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ObservationsCard(
                  observations: _observations.isNotEmpty ? _observations : [
                    {'text': 'No hay observaciones recientes', 'teacher': 'Por el momento'},
                  ],
                  onViewAll: () {
                    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
                    final currentStudent = studentProvider.currentStudent;
                    if (currentStudent != null) {
                      DashboardModals.showObservationsModal(context, currentStudent.enrollment.id);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ArrivalHistoryChart extends StatefulWidget {
  final String? enrollmentId;
  
  const ArrivalHistoryChart({Key? key, this.enrollmentId}) : super(key: key);

  @override
  State<ArrivalHistoryChart> createState() => _ArrivalHistoryChartState();
}

class _ArrivalHistoryChartState extends State<ArrivalHistoryChart> {
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = true;
  DateTime _selectedWeekStart = DateTime.now();
  final supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = _getWeekStart(DateTime.now());
    _fetchAttendanceData();
  }

  DateTime _getWeekStart(DateTime date) {
    // Calcular el inicio de semana desde el domingo (weekday 7 = domingo, 1 = lunes)
    // Si es domingo (weekday = 7), no restar días
    // Si es lunes (weekday = 1), restar 1 día para llegar al domingo
    // Si es martes (weekday = 2), restar 2 días para llegar al domingo, etc.
    final daysToSubtract = date.weekday == 7 ? 0 : date.weekday;
    return date.subtract(Duration(days: daysToSubtract));
  }

  Future<void> _fetchAttendanceData() async {
    // Usar un enrollment_id real de la base de datos si no se proporciona uno
    final enrollmentId = widget.enrollmentId ?? '8552773b-5390-4952-a086-eaa9579f4700';
    
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // Obtener datos de asistencia para la semana seleccionada
      final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
      
      final response = await supabaseClient
          .from('enrollment_attendances')
          .select('date, check_in_time, status')
          .eq('enrollment_id', enrollmentId)
          .gte('date', _selectedWeekStart.toIso8601String().split('T')[0])
          .lte('date', weekEnd.toIso8601String().split('T')[0])
          .eq('status', 'present')
          .order('date', ascending: true);

      if (mounted) {
        setState(() {
          _attendanceData = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateWeek(int direction) {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(Duration(days: 7 * direction));
    });
    _fetchAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
    
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DashboardColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DashboardColors.cardBorder : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header con navegación semanal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${DateFormat('d MMM', 'es').format(_selectedWeekStart)} - ${DateFormat('d MMM', 'es').format(weekEnd)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? DashboardColors.primaryText : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: isDark ? DashboardColors.primaryText : const Color(0xFF0F172A),
                    ),
                    onPressed: () => _navigateWeek(-1),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: isDark ? DashboardColors.primaryText : const Color(0xFF0F172A),
                    ),
                    onPressed: () => _navigateWeek(1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Gráfico
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: isDark ? DashboardColors.primaryText : const Color(0xFF3B82F6),
                    ),
                  )
                : _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_attendanceData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart, 
              size: 48, 
              color: isDark ? DashboardColors.tertiaryText : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay datos de asistencia',
              style: TextStyle(
                color: isDark ? DashboardColors.secondaryText : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'para esta semana',
              style: TextStyle(
                color: isDark ? DashboardColors.tertiaryText : const Color(0xFF9CA3AF), 
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Procesar datos para el gráfico
    final chartData = _processChartData();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 24, // 24 horas
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: isDark ? const Color(0xFF374151) : const Color(0xFF1F2937),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (group.x.toInt() < chartData.length) {
                final date = chartData[group.x.toInt()]['date'];
                final hour = rod.toY;
                final dayName = chartData[group.x.toInt()]['dayName'];
                if (hour > 0) {
                  // Convertir la hora decimal a formato HH:MM am/pm
                  final hours = hour.floor();
                  final minutes = ((hour - hours) * 60).round();
                  final time = DateTime(2024, 1, 1, hours, minutes);
                  final timeString = DateFormat('hh:mm a').format(time);
                  
                  return BarTooltipItem(
                    '$dayName\n$date\n$timeString',
                    const TextStyle(color: Colors.white),
                  );
                } else {
                  return BarTooltipItem(
                    '$dayName\n$date\nSin registro',
                    const TextStyle(color: Colors.white),
                  );
                }
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  final data = chartData[value.toInt()];
                  final dayName = data['dayName'];
                  final date = data['date'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? DashboardColors.tertiaryText : const Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark ? DashboardColors.tertiaryText : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}:00',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? DashboardColors.tertiaryText : const Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final isToday = data['isToday'] ?? false;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data['hour'].toDouble(),
                color: data['hour'] > 0 
                    ? (isToday ? DashboardColors.accentGreen : DashboardColors.barBlue)
                    : (isDark ? DashboardColors.cardBorder : const Color(0xFFF3F4F6)),
                width: 25,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _processChartData() {
    final List<Map<String, dynamic>> result = [];
    final now = DateTime.now();
    
    // Crear lista de 7 días de la semana seleccionada
    for (int i = 0; i < 7; i++) {
      final date = _selectedWeekStart.add(Duration(days: i));
      final dateStr = DateFormat('dd/MM').format(date);
      final dayName = DateFormat('EEE', 'es').format(date);
      final isToday = now.year == date.year && 
                     now.month == date.month && 
                     now.day == date.day;
      
      // Buscar datos de asistencia para esta fecha
      final attendanceForDate = _attendanceData.where((data) {
        final dataDate = DateTime.parse(data['date']);
        return dataDate.year == date.year && 
               dataDate.month == date.month && 
               dataDate.day == date.day;
      }).toList();

      double hour = 0.0;
      if (attendanceForDate.isNotEmpty && attendanceForDate.first['check_in_time'] != null) {
        final checkInTime = attendanceForDate.first['check_in_time'] as String?;
        if (checkInTime != null) {
          try {
            // Parsear el timestamp con timezone y convertir a hora local
            final utcTime = DateTime.parse(checkInTime);
            final localTime = utcTime.toLocal();
            
            // Extraer hora y minutos de la hora local
            hour = localTime.hour.toDouble() + (localTime.minute / 60.0);
          } catch (e) {
            print('Error parsing time with timezone: $e');
            hour = 0.0;
          }
        }
      }

      result.add({
        'date': dateStr,
        'dayName': dayName,
        'hour': hour,
        'isToday': isToday,
      });
    }

    return result;
  }
}
