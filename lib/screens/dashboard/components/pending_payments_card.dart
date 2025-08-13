import 'package:flutter/material.dart';
import 'package:zypher/core/constants/dashboard_colors.dart';

class PendingPaymentsCard extends StatelessWidget {
  final List<Map<String, String>> payments;
  final VoidCallback? onGoToPay;

  const PendingPaymentsCard({
    Key? key,
    required this.payments,
    this.onGoToPay,
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
                    Icons.payment,
                    color: const Color(0xFFF87171),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pagos Pendientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? DashboardColors.primaryText : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (onGoToPay != null)
                GestureDetector(
                  onTap: onGoToPay,
                  child: Row(
                    children: [
                      Text(
                        'Ir a pagar',
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
            children: payments.asMap().entries.map((entry) {
              final index = entry.key;
              final payment = entry.value;
              final isLast = index == payments.length - 1;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          payment['concept'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? DashboardColors.secondaryText : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      Text(
                        payment['dueDate'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF87171),
                          fontWeight: FontWeight.w500,
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
