import 'package:flutter/material.dart';
import 'package:zypher/domain/enrollment/models/enrollment.dart';
import 'package:zypher/core/providers/student_provider.dart';
import 'package:zypher/core/constants/dashboard_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DashboardColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? DashboardColors.cardBorder : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: isDark ? DashboardColors.tertiaryText : const Color(0xFF6B7280),
            ),
            onPressed: studentProvider.currentIndex > 0
                ? () => studentProvider.changeStudent(studentProvider.currentIndex - 1)
                : null,
          ),
          CircleAvatar(
            radius: 24,
            backgroundImage: student.thumbnail != null ? NetworkImage(student.thumbnail!) : null,
            backgroundColor: isDark ? DashboardColors.cardBorder : const Color(0xFFF3F4F6),
            child: student.thumbnail == null
                ? Text(
                    '${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}',
                    style: TextStyle(
                      color: isDark ? DashboardColors.primaryText : const Color(0xFF6B7280),
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
                    color: isDark ? DashboardColors.primaryText : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${grade.level.toString().split('.').last} / ${grade.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? DashboardColors.tertiaryText : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon:               Icon(
                Icons.chevron_right,
                color: isDark ? DashboardColors.tertiaryText : const Color(0xFF6B7280),
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