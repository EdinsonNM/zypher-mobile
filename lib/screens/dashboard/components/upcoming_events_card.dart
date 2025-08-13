import 'package:flutter/material.dart';
import 'package:zypher/core/constants/dashboard_colors.dart';

class UpcomingEventsCard extends StatelessWidget {
  final List<Map<String, String>> events;
  final VoidCallback? onViewAll;

  const UpcomingEventsCard({
    Key? key,
    required this.events,
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
                    Icons.event,
                    color: DashboardColors.accentYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Próximos Eventos',
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
                        'Ver todos',
                        style: TextStyle(
                          fontSize: 14,
                          color: DashboardColors.accentBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: DashboardColors.accentBlue,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Column(
            children: events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isLast = index == events.length - 1;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event['text'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? DashboardColors.secondaryText : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      Text(
                        event['date'] ?? '',
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
