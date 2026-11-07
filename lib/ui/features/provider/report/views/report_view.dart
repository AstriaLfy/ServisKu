import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/ui/features/provider/report/bloc/report_cubit.dart';
import 'package:servis_ku/ui/features/provider/report/bloc/report_state.dart';
import 'package:servis_ku/ui/features/provider/report/domain/report_models.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_widgets.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  @override
  void initState() {
    super.initState();
    context.read<ReportCubit>().load();
  }

  Future<void> _withdraw() async {
    final cubit = context.read<ReportCubit>();
    final withdrawal = await cubit.withdraw();
    if (!mounted) return;

    if (withdrawal != null) {
      context.push('/provider/report/result', extra: withdrawal);
    } else if (cubit.state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.state.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<ReportCubit, ReportState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<ReportCubit>().load(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laporan',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ReportMonthDropdown(
                      months: state.months,
                      selected: state.selectedMonth,
                      onChanged: context.read<ReportCubit>().selectMonth,
                    ),
                    const SizedBox(height: 20),
                    if (state.status == ReportStatus.initial ||
                        state.status == ReportStatus.loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.status == ReportStatus.failure)
                      _buildError(state)
                    else ...[
                      _buildRevenueSummaryCard(state),
                      const SizedBox(height: 16),
                      _buildWithdrawalCard(state),
                      const SizedBox(height: 24),
                      _buildTransactionHistoryHeader(),
                      const SizedBox(height: 12),
                      _buildTransactionList(state.summary),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(ReportState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Text(
              state.errorMessage ?? 'Gagal memuat laporan.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.read<ReportCubit>().load(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummaryCard(ReportState state) {
    final summary = state.summary;
    final trend = state.trendPercent;
    final isUp = (trend ?? 0) >= 0;
    final trendColor = isUp ? const Color(0xFF16A34A) : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Ringkasan Pendapatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (trend != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUp ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUp ? Icons.trending_up : Icons.trending_down,
                            color: trendColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${trend.abs().round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: trendColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Dibanding ${state.previousSummary.monthLabel}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Pendapatan Bersih',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(summary.net),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFCBD5E1), height: 1, thickness: 1),
          const SizedBox(height: 14),
          _buildSummaryRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Pendapatan Kotor',
            value: CurrencyFormatter.format(summary.gross),
            valueColor: const Color(0xFF111827),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            icon: Icons.stars_rounded,
            label: 'Potongan Komisi (${ReportSummary.commissionPercent}%)',
            value: '-${CurrencyFormatter.format(summary.commission)}',
            valueColor: AppColors.danger,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalCard(ReportState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Siap Dicairkan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(state.availableBalance),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Minimal pencairan ${CurrencyFormatter.format(Withdrawal.minimumAmount)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Cairkan Dana',
            isLoading: state.isWithdrawing,
            prefixIcon: const Icon(
              Icons.file_download_outlined,
              color: Colors.white,
              size: 20,
            ),
            onPressed: state.canWithdraw ? _withdraw : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistoryHeader() {
    return Row(
      children: [
        const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.push('/provider/report/details'),
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(ReportSummary summary) {
    if (summary.transactions.isEmpty) {
      return ReportEmptyTransactions(monthLabel: summary.monthLabel);
    }

    return Column(
      children: summary.transactions
          .take(3)
          .map((transaction) => ReportTransactionTile(transaction: transaction))
          .toList(),
    );
  }
}
