import 'package:flutter/material.dart';
import 'package:zypher/core/constants/dashboard_colors.dart';

class ObservationsCard extends StatelessWidget {
  final List<Map<String, String>> observations;
  final VoidCallback? onViewAll;

  const ObservationsCard({
    Key? key,
    required this.observations,
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
                    Icons.visibility,
                    color: const Color(0xFF34D399),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Observaciones',
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
            children: observations.asMap().entries.map((entry) {
              final index = entry.key;
              final observation = entry.value;
              final isLast = index == observations.length - 1;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          observation['text'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? DashboardColors.secondaryText : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      Text(
                        observation['teacher'] ?? '',
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
