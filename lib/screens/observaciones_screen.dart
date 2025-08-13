import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/core/providers/student_provider.dart';
import 'package:zypher/domain/enrollment/models/enrollment_observation.dart';
import 'package:zypher/domain/enrollment/services/enrollment_obsevation_service_repository.dart';
import 'package:zypher/domain/enrollment/usecases/get_events_by_enrollment.usecase.dart';
import 'package:intl/intl.dart';

class ObservacionesScreen extends StatefulWidget {
  const ObservacionesScreen({super.key});

  @override
  State<ObservacionesScreen> createState() => _ObservacionesScreenState();
}

class _ObservacionesScreenState extends State<ObservacionesScreen> {
  List<EnrollmentObservation> _observations = [];
  bool _isLoading = true;
  bool _filterByDate = true; // true = por fecha, false = por categoría

  @override
  void initState() {
    super.initState();
    _fetchObservations();
  }

  Future<void> _fetchObservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final currentStudent = studentProvider.currentStudent;
      if (currentStudent == null) return;

      final observations = await GetEventsByEnrollmentUseCase(
        observationRepository: EnrollmentObservationServiceRepository(
          Supabase.instance.client,
        ),
      ).execute(enrollmentId: currentStudent.enrollment.id);

      if (mounted) {
        setState(() {
          _observations = observations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'alta':
        return Icons.assignment_late;
      case 'media':
        return Icons.report_problem;
      case 'baja':
        return Icons.star;
      default:
        return Icons.info;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final observationDate = DateTime(date.year, date.month, date.day);

    if (observationDate == today) {
      return 'Hoy, ${DateFormat('dd \'de\' MMMM yyyy', 'es').format(date)}';
    } else if (observationDate == yesterday) {
      return 'Ayer, ${DateFormat('dd \'de\' MMMM yyyy', 'es').format(date)}';
    } else {
      return DateFormat('dd \'de\' MMMM yyyy', 'es').format(date);
    }
  }

  String _getTimeString(DateTime date) {
    return DateFormat('hh:mm a', 'es').format(date);
  }

  List<EnrollmentObservation> _getSortedObservations() {
    if (_filterByDate) {
      // Sort by date (newest first)
      final sorted = List<EnrollmentObservation>.from(_observations);
      sorted.sort((a, b) => b.date.compareTo(a.date));
      return sorted;
    } else {
      // Sort by category, then by date
      final sorted = List<EnrollmentObservation>.from(_observations);
      sorted.sort((a, b) {
        final categoryComparison = (a.category?.name ?? '').compareTo(b.category?.name ?? '');
        if (categoryComparison != 0) return categoryComparison;
        return b.date.compareTo(a.date);
      });
      return sorted;
    }
  }

  Map<String, List<EnrollmentObservation>> _groupObservationsByDate() {
    final sortedObservations = _getSortedObservations();
    final grouped = <String, List<EnrollmentObservation>>{};

    for (final observation in sortedObservations) {
      final dateKey = _getRelativeDate(observation.date);
      grouped.putIfAbsent(dateKey, () => []).add(observation);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentStudent = studentProvider.currentStudent;

    if (currentStudent == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF111827),
        body: Center(
          child: Text(
            'No hay estudiante seleccionado',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Observaciones',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 32), // Balance the back button
              ],
            ),
          ),

          // Student Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: currentStudent.student.thumbnail != null
                      ? NetworkImage(currentStudent.student.thumbnail!)
                      : null,
                  child: currentStudent.student.thumbnail == null
                      ? Text(
                          '${currentStudent.student.firstName.isNotEmpty ? currentStudent.student.firstName[0] : ''}${currentStudent.student.lastName.isNotEmpty ? currentStudent.student.lastName[0] : ''}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                        '${currentStudent.student.firstName} ${currentStudent.student.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${currentStudent.grade.level.toString()} / ${currentStudent.grade.name}',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Filter Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _filterByDate = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _filterByDate ? const Color(0xFF3B82F6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Por Fecha',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _filterByDate ? Colors.white : const Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _filterByDate = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: !_filterByDate ? const Color(0xFF3B82F6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Por Categoría',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_filterByDate ? Colors.white : const Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Observations List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                    ),
                  )
                : _observations.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _fetchObservations,
                        color: const Color(0xFF3B82F6),
                        child: const Center(
                          child: Text(
                            'No hay observaciones registradas',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchObservations,
                        color: const Color(0xFF3B82F6),
                        child: _buildObservationsList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsList() {
    if (_filterByDate) {
      return _buildObservationsByDate();
    } else {
      return _buildObservationsByCategory();
    }
  }

  Widget _buildObservationsByDate() {
    final groupedObservations = _groupObservationsByDate();
    final sortedDates = groupedObservations.keys.toList()
      ..sort((a, b) {
        // Sort dates: today first, then yesterday, then by actual date
        final today = 'Hoy, ${DateFormat('dd \'de\' MMMM yyyy', 'es').format(DateTime.now())}';
        final yesterday = 'Ayer, ${DateFormat('dd \'de\' MMMM yyyy', 'es').format(DateTime.now().subtract(const Duration(days: 1)))}';
        
        if (a == today) return -1;
        if (b == today) return 1;
        if (a == yesterday) return -1;
        if (b == yesterday) return 1;
        
        // For other dates, sort by actual date
        final aDate = _observations.firstWhere((obs) => _getRelativeDate(obs.date) == a).date;
        final bDate = _observations.firstWhere((obs) => _getRelativeDate(obs.date) == b).date;
        return bDate.compareTo(aDate);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final observations = groupedObservations[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...observations.map((observation) => _buildObservationCard(observation)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildObservationsByCategory() {
    final groupedObservations = <String, List<EnrollmentObservation>>{};
    
    for (final observation in _observations) {
      final categoryName = observation.category?.name ?? 'Sin Categoría';
      groupedObservations.putIfAbsent(categoryName, () => []).add(observation);
    }

    final sortedCategories = groupedObservations.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final observations = groupedObservations[category]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                category,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...observations.map((observation) => _buildObservationCard(observation)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildObservationCard(EnrollmentObservation observation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSeverityColor(observation.severity).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSeverityColor(observation.severity).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getSeverityIcon(observation.severity),
              color: _getSeverityColor(observation.severity),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  observation.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  observation.description,
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                   
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeString(observation.date),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 