import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/ui/features/provider/report/domain/report_models.dart';

class ReportResultView extends StatelessWidget {
  final Withdrawal? withdrawal;

  const ReportResultView({super.key, this.withdrawal});

  @override
  Widget build(BuildContext context) {
    final data = withdrawal;
    final amount = data == null ? '-' : CurrencyFormatter.format(data.amount);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      const Spacer(),

                      Image.asset(
                        'assets/images/success.png',
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Pencairan Dana',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const Text(
                        'Berhasil!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Pengajuan pencairan dana sebesar\n$amount telah berhasil dibuat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFF3F4F6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              label: 'Nomor Referensi',
                              value: data?.reference ?? '-',
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              label: 'Metode Pencairan',
                              value: data?.method ?? '-',
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(label: 'Jumlah', value: amount),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              label: 'Estimasi Dana\nDiterima',
                              value: data == null
                                  ? '-'
                                  : '${data.estimatedArrival} WIB',
                              alignValueRight: true,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      CustomButton(
                        text: 'Tutup',
                        onPressed: () {
                          context.pop();
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool alignValueRight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}
