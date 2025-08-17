import 'package:flutter/material.dart';
import 'package:zypher/domain/enrollment/models/enrollment.dart';
import 'package:zypher/core/providers/student_provider.dart';
import 'package:zypher/core/constants/theme_colors.dart';

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
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(theme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeColors.getCardBorder(theme),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: ThemeColors.getTertiaryText(theme),
            ),
            onPressed: studentProvider.currentIndex > 0
                ? () => studentProvider.changeStudent(studentProvider.currentIndex - 1)
                : null,
          ),
          CircleAvatar(
            radius: 24,
            backgroundImage: student.thumbnail != null ? NetworkImage(student.thumbnail!) : null,
            backgroundColor: ThemeColors.getCardBorder(theme),
            child: student.thumbnail == null
                ? Text(
                    '${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}',
                    style: TextStyle(
                      color: ThemeColors.getPrimaryText(theme),
                      fontWeight: FontWeight.w600,
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
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.getPrimaryText(theme),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${grade.level.toString().split('.').last} / ${grade.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.getTertiaryText(theme),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: ThemeColors.getTertiaryText(theme),
            ),
            onPressed: studentProvider.currentIndex < studentProvider.students.length - 1
                ? () => studentProvider.changeStudent(studentProvider.currentIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }
} 