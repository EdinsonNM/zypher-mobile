import 'package:flutter/material.dart';
import 'package:zypher/core/constants/dashboard_colors.dart';

class NotificationsCard extends StatelessWidget {
  final List<Map<String, String>> notifications;
  final VoidCallback? onViewAll;

  const NotificationsCard({
    Key? key,
    required this.notifications,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DashboardColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? DashboardColors.cardBorder : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications,
                    color: const Color(0xFF60A5FA),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? DashboardColors.primaryText : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    children: [
                      Text(
                        'Ver todas',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF60A5FA),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: const Color(0xFF60A5FA),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Column(
            children: notifications.asMap().entries.map((entry) {
              final index = entry.key;
              final notification = entry.value;
              final isLast = index == notifications.length - 1;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification['text'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? DashboardColors.secondaryText : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      Text(
                        notification['time'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? DashboardColors.tertiaryText : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        color: isDark ? DashboardColors.dividerColor : const Color(0xFFE5E7EB),
                        height: 1,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
