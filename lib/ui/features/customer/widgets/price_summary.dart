import 'package:flutter/material.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/ui/features/customer/booking/domain/booking_pricing.dart';

class PriceSummary extends StatelessWidget {
  final List<PriceLine> lines;
  final int serviceFee;

  const PriceSummary({
    super.key,
    required this.lines,
    this.serviceFee = BookingPricing.serviceFee,
  });

  int get total => BookingPricing.subtotal(lines) + serviceFee;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...lines.map((line) => _row(line.label, line.amount)),
        _row('Biaya layanan', serviceFee),
        const SizedBox(height: 4),
        _row('Total', total, isTotal: true),
      ],
    );
  }

  Widget _row(String label, int amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 13 : 12,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                color: isTotal ? const Color(0xFF111827) : const Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: isTotal ? 15 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
