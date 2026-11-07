import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/ui/features/provider/report/bloc/report_cubit.dart';
import 'package:servis_ku/ui/features/provider/report/bloc/report_state.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_widgets.dart';

class ReportDetailsView extends StatefulWidget {
  const ReportDetailsView({super.key});

  @override
  State<ReportDetailsView> createState() => _ReportDetailsViewState();
}

class _ReportDetailsViewState extends State<ReportDetailsView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReportCubit>();
    if (cubit.state.status != ReportStatus.loaded) cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<ReportCubit, ReportState>(
          builder: (context, state) {
            final summary = state.summary;

            return RefreshIndicator(
              onRefresh: () => context.read<ReportCubit>().load(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
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
                    else if (summary.transactions.isEmpty)
                      ReportEmptyTransactions(monthLabel: summary.monthLabel)
                    else
                      ...summary.transactions.map(
                        (transaction) => ReportTransactionTile(transaction: transaction),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        const Center(
          child: Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}
