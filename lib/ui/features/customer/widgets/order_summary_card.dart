import 'package:flutter/material.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/ui/features/customer/order/domain/customer_order.dart';
import 'package:servis_ku/ui/features/customer/widgets/order_status_badge.dart';

class OrderSummaryCard extends StatelessWidget {
  final String title;
  final CustomerOrder order;
  final VoidCallback? onTap;
  final int maxLines;

  const OrderSummaryCard({
    super.key,
    required this.title,
    required this.order,
    this.onTap,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    final lines = order.serviceLines;
    final visibleLines = lines.take(maxLines).toList();
    final hiddenCount = lines.length - visibleLines.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Pesanan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              ...visibleLines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    line,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                  ),
                ),
              ),
              if (hiddenCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '+$hiddenCount layanan lainnya',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  CurrencyFormatter.format(order.total),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  order.formattedDate,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
