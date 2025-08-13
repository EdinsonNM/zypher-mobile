import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zypher/domain/enrollment/models/enrollment_observation.dart';
import 'package:zypher/domain/enrollment/services/enrollment_obsevation_service_repository.dart';
import 'package:zypher/domain/enrollment/usecases/get_events_by_enrollment.usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardModals {
  static void showObservationsModal(BuildContext context, String enrollmentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ObservationsModalContent(enrollmentId: enrollmentId),
    );
  }

  static void showPaymentsModal(BuildContext context, String enrollmentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentsModalContent(enrollmentId: enrollmentId),
    );
  }
}

class _ObservationsModalContent extends StatefulWidget {
  final String enrollmentId;

  const _ObservationsModalContent({required this.enrollmentId});

  @override
  State<_ObservationsModalContent> createState() => _ObservationsModalContentState();
}

class _ObservationsModalContentState extends State<_ObservationsModalContent> {
  List<EnrollmentObservation> _observations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchObservations();
  }

  Future<void> _fetchObservations() async {
    try {
      final observations = await GetEventsByEnrollmentUseCase(
        observationRepository: EnrollmentObservationServiceRepository(
          Supabase.instance.client,
        ),
      ).execute(enrollmentId: widget.enrollmentId);
      
      if (mounted) {
        setState(() {
          _observations = observations.take(5).toList(); // Solo las 5 últimas
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

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: const Color(0xFFF59E0B),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Últimas Observaciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _observations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay observaciones recientes',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _observations.length,
                        itemBuilder: (context, index) {
                          final observation = _observations[index];
                          final severityColor = _getSeverityColor(observation.severity);
                          final dateFormat = DateFormat('dd/MM/yyyy');
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: severityColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          observation.severity.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: severityColor,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        dateFormat.format(observation.date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    observation.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    observation.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                                    ),
                                  ),
                                  if (observation.category != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        observation.category!.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsModalContent extends StatefulWidget {
  final String enrollmentId;

  const _PaymentsModalContent({required this.enrollmentId});

  @override
  State<_PaymentsModalContent> createState() => _PaymentsModalContentState();
}

class _PaymentsModalContentState extends State<_PaymentsModalContent> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingPayments = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingPayments();
  }

  Future<void> _fetchPendingPayments() async {
    // Simulación de datos de pagos pendientes
    // En una implementación real, esto vendría de la base de datos
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _pendingPayments = [
          {
            'concept': 'Matrícula Marzo 2024',
            'amount': 150.00,
            'dueDate': DateTime.now().add(const Duration(days: 5)),
            'status': 'pendiente',
          },
          {
            'concept': 'Mensualidad Abril 2024',
            'amount': 120.00,
            'dueDate': DateTime.now().add(const Duration(days: 15)),
            'status': 'pendiente',
          },
          {
            'concept': 'Materiales Escolares',
            'amount': 45.00,
            'dueDate': DateTime.now().add(const Duration(days: 2)),
            'status': 'vencido',
          },
        ];
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'vencido':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.payment,
                  color: const Color(0xFFEF4444),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pagos Pendientes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pendingPayments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay pagos pendientes',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _pendingPayments.length,
                        itemBuilder: (context, index) {
                          final payment = _pendingPayments[index];
                          final statusColor = _getStatusColor(payment['status']);
                          final dateFormat = DateFormat('dd/MM/yyyy');
                          final isOverdue = payment['dueDate'].isBefore(DateTime.now());
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          payment['status'].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '\$${payment['amount'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    payment['concept'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Vence: ${dateFormat.format(payment['dueDate'])}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isOverdue 
                                              ? Colors.red 
                                              : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

