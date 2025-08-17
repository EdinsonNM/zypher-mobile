import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/core/providers/student_provider.dart';
import 'package:zypher/domain/enrollment/models/enrollment.dart';
import 'package:zypher/core/constants/theme_colors.dart';

class AsistenciasScreen extends StatefulWidget {
  const AsistenciasScreen({super.key});

  @override
  State<AsistenciasScreen> createState() => _AsistenciasScreenState();
}

class _AsistenciasScreenState extends State<AsistenciasScreen> {
  DateTime _selectedMonth = DateTime.now();
  final supabaseClient = Supabase.instance.client;

  // Datos de ejemplo para el calendario (en un caso real vendrían de la base de datos)
  final Map<int, String> _attendanceData = {
    1: 'present',
    2: 'present',
    3: 'present',
    4: 'present',
    7: 'present',
    8: 'late',
    9: 'present',
    10: 'present',
    11: 'absent',
    14: 'present',
    15: 'present',
    16: 'present',
    17: 'present',
    18: 'present',
    21: 'present',
    22: 'present',
    23: 'late',
    24: 'present',
    25: 'present',
    28: 'present',
    29: 'present',
    30: 'present',
    31: 'absent',
  };

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentStudent = studentProvider.currentStudent;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(theme),
      body: Column(
        children: [

          
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (currentStudent != null) _buildStudentInfo(currentStudent, theme),
                  const SizedBox(height: 24),
                  _buildMonthlyCalendar(theme),
                  const SizedBox(height: 24),
                  _buildMonthlySummary(theme),
                  const SizedBox(height: 16),
                  _buildDetailedReportButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildStudentInfo(EnrollmentWithRelations enrollment, ThemeData theme) {
    final student = enrollment.student;
    final grade = enrollment.grade;
    
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: student.thumbnail != null 
              ? NetworkImage(student.thumbnail!) 
              : null,
          backgroundColor: student.thumbnail == null 
              ? Colors.grey[600] 
              : null,
          child: student.thumbnail == null
              ? Text(
                  '${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}',
                  style: TextStyle(
                    color: ThemeColors.getPrimaryText(theme),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.getPrimaryText(theme),
                ),
              ),
              Text(
                '${grade.level.toString().split('.').last} / ${grade.name}',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeColors.getTertiaryText(theme), // text-gray-400
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyCalendar(ThemeData theme) {
    final monthName = DateFormat('MMMM yyyy', 'es').format(_selectedMonth);
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = lunes, 7 = domingo
    
    // Ajustar para que la semana empiece en lunes
    final adjustedFirstWeekday = firstWeekday == 7 ? 0 : firstWeekday - 1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(theme), // bg-gray-800
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header del mes con navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getPrimaryText(theme),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: ThemeColors.getCardBorder(theme), // bg-gray-700
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: 16,
                        color: ThemeColors.getPrimaryText(theme),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: ThemeColors.getCardBorder(theme), // bg-gray-700
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: 16,
                        color: ThemeColors.getPrimaryText(theme),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Días de la semana
          Row(
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) => 
              Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.getTertiaryText(theme), // text-gray-400
                  ),
                ),
              )
            ).toList(),
          ),
          const SizedBox(height: 8),
          
          // Calendario
          _buildCalendarGrid(adjustedFirstWeekday, lastDayOfMonth.day, theme),
          
          // Leyenda
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Presente', const Color(0xFF10B981), theme), // bg-green-500
              _buildLegendItem('Ausente', const Color(0xFFEF4444), theme), // bg-red-500
              _buildLegendItem('Tardanza', const Color(0xFFF59E0B), theme), // bg-yellow-500
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(int firstWeekday, int lastDay, ThemeData theme) {
    final totalCells = firstWeekday + lastDay;
    final rows = (totalCells / 7).ceil();
    
    return Column(
      children: List.generate(rows, (rowIndex) {
        return Row(
          children: List.generate(7, (colIndex) {
            final cellIndex = rowIndex * 7 + colIndex;
            final dayNumber = cellIndex - firstWeekday + 1;
            
            if (cellIndex < firstWeekday || dayNumber > lastDay) {
              // Celda vacía
              return Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(2),
                ),
              );
            }
            
            final attendanceStatus = _attendanceData[dayNumber];
            Color backgroundColor;
            Color textColor = ThemeColors.getPrimaryText(theme);
            
            switch (attendanceStatus) {
              case 'present':
                backgroundColor = const Color(0xFF10B981); // bg-green-500
                break;
              case 'absent':
                backgroundColor = const Color(0xFFEF4444); // bg-red-500
                break;
              case 'late':
                backgroundColor = const Color(0xFFF59E0B); // bg-yellow-500
                break;
              default:
                backgroundColor = Colors.transparent;
                textColor = ThemeColors.getPrimaryText(theme);
            }
            
            return Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ThemeColors.getPrimaryText(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySummary(ThemeData theme) {
    // Calcular estadísticas
    final presentDays = _attendanceData.values.where((status) => status == 'present').length;
    final absentDays = _attendanceData.values.where((status) => status == 'absent').length;
    final lateDays = _attendanceData.values.where((status) => status == 'late').length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del Mes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeColors.getTertiaryText(theme), // text-gray-400
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeColors.getCardBackground(theme), // bg-gray-800
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                Icons.check_circle,
                'Asistencias',
                '$presentDays días',
                const Color(0xFF34D399), // text-green-400
                theme,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                Icons.cancel,
                'Inasistencias',
                '$absentDays días',
                const Color(0xFFF87171), // text-red-400
                theme,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                Icons.watch_later,
                'Tardanzas',
                '$lateDays días',
                const Color(0xFFFBBF24), // text-yellow-400
                theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color iconColor, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: ThemeColors.getPrimaryText(theme),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: ThemeColors.getPrimaryText(theme),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedReportButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          // Navegar al reporte detallado
        },
        child: const Text(
          'Ver reporte detallado',
          style: TextStyle(
            color: Color(0xFF60A5FA), // text-blue-400
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _changeMonth(int direction) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + direction,
        1,
      );
    });
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF60A5FA),
              surface: ThemeColors.getCardBackground(Theme.of(context)),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }
}
