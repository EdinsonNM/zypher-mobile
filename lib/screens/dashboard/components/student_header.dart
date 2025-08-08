import 'package:flutter/material.dart';
import 'package:zypher/domain/enrollment/models/enrollment.dart';
import 'package:zypher/core/providers/student_provider.dart';

class StudentHeader extends StatelessWidget {
  final EnrollmentWithRelations studentEnrollment;
  final StudentProvider studentProvider;

  const StudentHeader({
    Key? key,
    required this.studentEnrollment,
    required this.studentProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
} 