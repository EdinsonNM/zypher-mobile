import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zypher/core/constants/dashboard_colors.dart';

class ArrivalHistoryChart extends StatefulWidget {
  const ArrivalHistoryChart({Key? key}) : super(key: key);

  @override
  State<ArrivalHistoryChart> createState() => _ArrivalHistoryChartState();
}

class _ArrivalHistoryChartState extends State<ArrivalHistoryChart> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;

  final List<String> _tabs = ['Semanal', 'Mensual', 'Anual'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: _selectedIndex);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: DashboardColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              tabBarTheme: const TabBarThemeData(
                overlayColor: MaterialStatePropertyAll(Colors.transparent),
                indicator: BoxDecoration(),
                dividerColor: Colors.transparent,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: DashboardColors.accentBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorColor: Colors.transparent,
              labelColor: DashboardColors.accentBlue,
              unselectedLabelColor: DashboardColors.tertiaryText,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 16),
              tabs: _tabs.map((e) => Tab(text: e)).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: _buildChart(_selectedIndex),
        ),
      ],
    );
  }

  Widget _buildChart(int index) {
    final now = DateTime.now();
    if (index == 0) {
      // Semanal: solo la semana vigente (lunes a domingo)
      final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final days = List.generate(7, (i) => firstDayOfWeek.add(Duration(days: i)));
      final labels = days.map((d) => _dayLetter(d.weekday)).toList();
      // Datos de ejemplo: puedes reemplazar por datos reales
      final data = List.generate(7, (i) => FlSpot(i.toDouble(), (2 + (i * 1.2) % 5)));
      return _lineChart(data, labels);
    } else if (index == 1) {
      // Mensual: solo el mes vigente
      final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
      final labels = List.generate(daysInMonth, (i) => (i + 1).toString());
      // Datos de ejemplo: puedes reemplazar por datos reales
      final data = List.generate(daysInMonth, (i) => FlSpot(i.toDouble(), (3 + (i % 7) * 0.7)));
      return _lineChart(data, labels, showEvery: (daysInMonth / 7).ceil());
    } else {
      // Anual: solo el año vigente
      final labels = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      // Datos de ejemplo: puedes reemplazar por datos reales
      final data = List.generate(12, (i) => FlSpot(i.toDouble(), (4 + (i % 5) * 1.1)));
      return _lineChart(data, labels);
    }
  }

  Widget _lineChart(List<FlSpot> data, List<String> labels, {int showEvery = 1}) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                if (idx >= 0 && idx < labels.length && idx % showEvery == 0) {
                  return Text(labels[idx], style: const TextStyle(fontSize: 12));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (labels.length - 1).toDouble(),
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  String _dayLetter(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'L';
      case DateTime.tuesday:
        return 'M';
      case DateTime.wednesday:
        return 'M';
      case DateTime.thursday:
        return 'J';
      case DateTime.friday:
        return 'V';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'D';
      default:
        return '';
    }
  }
} 