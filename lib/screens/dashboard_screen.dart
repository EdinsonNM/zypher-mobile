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
import 'package:provider/provider.dart';
import '../core/providers/student_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard/components/student_header.dart';
import 'dashboard/components/arrival_history_chart.dart';
import 'dashboard/components/stat_card.dart';
import 'dashboard/components/activity_list.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  List<EnrollmentEvent> _timelineItems = [];
  AcademicYear? _activePeriod;
  
  // Variables para estadísticas relevantes para padres
  double _attendancePercentage = 0.0;
  int _recentObservations = 0;
  int _upcomingParentEvents = 0;
  int _pendingPayments = 0;
  bool _isLoadingStats = false;
  
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
    _fetchAllStats();
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

  Future<void> _fetchAllStats() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final currentStudent = studentProvider.currentStudent;
    if (currentStudent == null || _activePeriod == null) return;

    setState(() => _isLoadingStats = true);

    try {
      final startDate = _activePeriod!.startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final endDate = _activePeriod!.endDate ?? DateTime.now();
      
      // Ejecutar todas las consultas en paralelo
      await Future.wait([
        _fetchAttendancePercentage(currentStudent.enrollment.id, startDate, endDate),
        _fetchRecentObservations(currentStudent.enrollment.id, startDate, endDate),
        _fetchUpcomingParentEvents(currentStudent.enrollment.id),
        _fetchPendingPayments(currentStudent.enrollment.id),
      ]);

      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _fetchAttendancePercentage(String enrollmentId, DateTime startDate, DateTime endDate) async {
    try {
      // Contar días totales con registro de asistencia
      final totalResponse = await supabaseClient
          .from('enrollment_attendances')
          .select('id')
          .eq('enrollment_id', enrollmentId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0]);

      // Contar días presentes
      final presentResponse = await supabaseClient
          .from('enrollment_attendances')
          .select('id')
          .eq('enrollment_id', enrollmentId)
          .eq('status', 'present')
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0]);

      final totalDays = totalResponse.length;
      final presentDays = presentResponse.length;

      if (mounted) {
        setState(() {
          _attendancePercentage = totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0;
        });
      }
    } catch (e) {
      print('Error fetching attendance: $e');
    }
  }

  Future<void> _fetchRecentObservations(String enrollmentId, DateTime startDate, DateTime endDate) async {
    try {
      // Contar observaciones recientes (últimos 30 días)
      final response = await supabaseClient
          .from('enrollment_observations')
          .select('id, severity, title')
          .eq('enrollment_id', enrollmentId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('created_at', ascending: false);

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
    try {
      // Buscar eventos de escuela de padres próximos
      final now = DateTime.now();
      final response = await supabaseClient
          .from('parent_school_events')
          .select('id, name, event_date, status')
          .gte('event_date', now.toIso8601String())
          .eq('status', 'scheduled')
          .order('event_date', ascending: true)
          .limit(5);

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

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentStudent = studentProvider.currentStudent;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentStudent != null)
                  StudentHeader(
                    studentEnrollment: currentStudent,
                    studentProvider: studentProvider,
                  ),
                const SizedBox(height: 16),
                Text(
                  'Historial de Llegada',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ArrivalHistoryChart(enrollmentId: currentStudent?.enrollment.id),
                const SizedBox(height: 24),
                Text(
                  'Información para Padres',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      StatCard(
                        title: 'Asistencia',
                        value: '${_attendancePercentage.toStringAsFixed(1)}%',
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                        isLoading: _isLoadingStats,
                        onTap: () {
                          // Navegar a vista detallada de asistencia
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Asistencia del período actual')),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Observaciones',
                        value: _recentObservations.toString(),
                        icon: Icons.assignment,
                        color: Colors.orange,
                        isLoading: _isLoadingStats,
                        onTap: () {
                          // Navegar a vista de observaciones
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Observaciones recientes del estudiante')),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Eventos Padres',
                        value: _upcomingParentEvents.toString(),
                        icon: Icons.event,
                        color: Colors.green,
                        isLoading: _isLoadingStats,
                        onTap: () {
                          // Navegar a eventos de escuela de padres
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Próximos eventos de Escuela de Padres')),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Pagos Pendientes',
                        value: _pendingPayments.toString(),
                        icon: Icons.payment,
                        color: Colors.red,
                        isLoading: _isLoadingStats,
                        onTap: () {
                          // Navegar a vista de pagos
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Estado de pagos de la matrícula')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Actividad Reciente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ActivityList(),
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
  String _selectedPeriod = 'week'; // 'week', 'month', '3months'
  final supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    // Usar un enrollment_id real de la base de datos si no se proporciona uno
    final enrollmentId = widget.enrollmentId ?? '8552773b-5390-4952-a086-eaa9579f4700';
    
    setState(() => _isLoading = true);

    try {
      // Obtener datos de asistencia según el período seleccionado
      final endDate = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case 'week':
          startDate = endDate.subtract(const Duration(days: 6));
          break;
        case 'month':
          startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
          break;
        case '3months':
          startDate = DateTime(endDate.year, endDate.month - 3, endDate.day);
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 6));
      }
      
      final response = await supabaseClient
          .from('enrollment_attendances')
          .select('date, check_in_time, status')
          .eq('enrollment_id', enrollmentId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
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

  void _changePeriod(String period) {
    setState(() => _selectedPeriod = period);
    _fetchAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Selector de período
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPeriodButton('Semana', 'week'),
              _buildPeriodButton('Mes', 'month'),
              _buildPeriodButton('3 Meses', '3months'),
            ],
          ),
          const SizedBox(height: 16),
          // Gráfico
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => _changePeriod(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_attendanceData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No hay datos de asistencia disponibles',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              'para el período seleccionado',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Procesar datos para el gráfico
    final chartData = _processChartData();

    // Usar gráfico de líneas para mes y 3 meses, barras para semana
    if (_selectedPeriod == 'week') {
      return _buildBarChartView(chartData);
    } else {
      return _buildLineChartView(chartData);
    }
  }

  Widget _buildBarChartView(List<Map<String, dynamic>> chartData) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 24, // 24 horas
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blue.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (group.x.toInt() < chartData.length) {
                final date = chartData[group.x.toInt()]['date'];
                final hour = rod.toY;
                return BarTooltipItem(
                  '${date}\n${hour.toStringAsFixed(1)}:00',
                  const TextStyle(color: Colors.white),
                );
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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  final data = chartData[value.toInt()];
                  if (data['showLabel'] == true) {
                    final date = data['date'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        date,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
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
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data['hour'].toDouble(),
                color: data['hour'] > 0 ? Colors.blue : Colors.grey[300],
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

  Widget _buildLineChartView(List<Map<String, dynamic>> chartData) {
    // Filtrar solo datos con valores > 0 para el gráfico de líneas
    final validData = chartData.where((data) => data['hour'] > 0).toList();
    
    if (validData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No hay datos de asistencia',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              'en este período',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 4,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _getXAxisInterval(),
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  final data = chartData[value.toInt()];
                  if (data['showLabel'] == true) {
                    final date = data['date'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        date,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
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
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: 0,
        maxY: 24,
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return FlSpot(index.toDouble(), data['hour'].toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blue.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final index = touchedSpot.x.toInt();
                if (index >= 0 && index < chartData.length) {
                  final date = chartData[index]['date'];
                  final hour = touchedSpot.y;
                  return LineTooltipItem(
                    '${date}\n${hour.toStringAsFixed(1)}:00',
                    const TextStyle(color: Colors.white),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _getXAxisInterval() {
    switch (_selectedPeriod) {
      case 'month':
        return 5; // Mostrar cada 5 días
      case '3months':
        return 15; // Mostrar cada 15 días
      default:
        return 1;
    }
  }

  List<Map<String, dynamic>> _processChartData() {
    final List<Map<String, dynamic>> result = [];
    final now = DateTime.now();
    
    int daysToShow;
    int interval;
    switch (_selectedPeriod) {
      case 'week':
        daysToShow = 7;
        interval = 1; // Mostrar todos los días
        break;
      case 'month':
        daysToShow = 30;
        interval = 3; // Mostrar cada 3 días
        break;
      case '3months':
        daysToShow = 90;
        interval = 7; // Mostrar cada semana
        break;
      default:
        daysToShow = 7;
        interval = 1;
    }
    
    // Crear lista de días según el período seleccionado
    for (int i = daysToShow - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      String dateStr;
      
      // Formato de fecha según el período
      switch (_selectedPeriod) {
        case 'week':
          dateStr = DateFormat('dd/MM').format(date);
          break;
        case 'month':
          dateStr = DateFormat('dd/MM').format(date);
          break;
        case '3months':
          dateStr = DateFormat('dd/MM').format(date);
          break;
        default:
          dateStr = DateFormat('dd/MM').format(date);
      }
      
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
            
            // Para Perú: UTC-5 (o UTC-4 durante horario de verano)
            // Usar toLocal() que automáticamente detecta la zona horaria del dispositivo
            final localTime = utcTime.toLocal();
            
            // Debug: Mostrar información de timezone
            print('=== TIMEZONE DEBUG ===');
            print('UTC Time: $utcTime');
            print('Local Time: $localTime');
            print('Timezone Offset: ${DateTime.now().timeZoneOffset}');
            print('Is UTC: ${utcTime.isUtc}');
            print('Is Local: ${localTime.isUtc}');
            print('Original check_in_time: $checkInTime');
            print('Hora local extraída: ${localTime.hour}:${localTime.minute}');
            print('======================');
            
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
        'hour': hour,
        'showLabel': i % interval == 0, // Solo mostrar etiqueta cada 'interval' días
      });
    }

    return result;
  }
}
