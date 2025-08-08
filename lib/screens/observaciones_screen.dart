import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zypher/core/providers/student_provider.dart';
import 'package:zypher/domain/enrollment/models/enrollment_observation.dart';
import 'package:zypher/domain/enrollment/services/enrollment_obsevation_service_repository.dart';
import 'package:zypher/domain/enrollment/usecases/get_events_by_enrollment.usecase.dart';
import 'package:intl/intl.dart';
import 'package:zypher/screens/dashboard/components/student_profile_card.dart';
import 'dashboard/components/student_header.dart';

class ObservacionesScreen extends StatefulWidget {
  const ObservacionesScreen({super.key});

  @override
  State<ObservacionesScreen> createState() => _ObservacionesScreenState();
}

class _ObservacionesScreenState extends State<ObservacionesScreen> {
  List<EnrollmentObservation> _observations = [];

  @override
  void initState() {
    super.initState();
    _fetchObservations();
  }

  Future<void> _fetchObservations() async {
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
      });
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
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentStudent = studentProvider.currentStudent;
    if (_observations.isEmpty) {
      return CustomScrollView(
        slivers: [
          if (currentStudent != null)
            SliverToBoxAdapter(
              child: StudentProfileCard(
                nombreCompleto: '${currentStudent.student.firstName} ${currentStudent.student.lastName}',
                grado: '${currentStudent.grade.level.toString().split('.').last} / ${currentStudent.grade.name}',
                avatarUrl: currentStudent.student.thumbnail,
              ),
            ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'No hay observaciones registradas',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        if (currentStudent != null)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyStudentHeaderDelegate(
              child: StudentHeader(
                studentEnrollment: currentStudent,
                studentProvider: studentProvider,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final observation = _observations[index];
                final severityColor = _getSeverityColor(observation.severity);
                final dateFormat = DateFormat('dd/MM/yyyy');
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: severityColor),
                              ),
                              child: Text(
                                observation.severity.toUpperCase(),
                                style: TextStyle(
                                  color: severityColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (observation.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Text(
                                  observation.category!.name,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Text(
                              dateFormat.format(observation.date),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          observation.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          observation.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        if (observation.resolutionNotes != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notas de resolución:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  observation.resolutionNotes!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              childCount: _observations.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _StickyStudentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyStudentHeaderDelegate({required this.child, this.height = 90});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
} 