import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/provider/report/domain/report_models.dart';

enum ReportStatus { initial, loading, loaded, failure }

class ReportState extends Equatable {
  final ReportStatus status;
  final List<ReportTransaction> transactions;
  final DateTime selectedMonth;
  final ProviderBalance? balance;
  final bool isWithdrawing;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.initial,
    this.transactions = const [],
    required this.selectedMonth,
    this.balance,
    this.isWithdrawing = false,
    this.errorMessage,
  });

  factory ReportState.initial() {
    final now = DateTime.now();
    return ReportState(selectedMonth: DateTime(now.year, now.month));
  }

  List<DateTime> get months {
    final now = DateTime.now();
    return List.generate(6, (index) => DateTime(now.year, now.month - 5 + index));
  }

  ReportSummary get summary => ReportSummary.forMonth(selectedMonth, transactions);

  ReportSummary get previousSummary => ReportSummary.forMonth(
        DateTime(selectedMonth.year, selectedMonth.month - 1),
        transactions,
      );

  double? get trendPercent {
    final previous = previousSummary.net;
    if (previous <= 0) return null;
    return (summary.net - previous) / previous * 100;
  }

  int get availableBalance {
    final value = balance?.available;
    if (value != null) return value;
    final gross = transactions.fold<int>(0, (sum, t) => sum + t.amount);
    return gross - (gross * ReportSummary.commissionRate).round();
  }

  bool get canWithdraw =>
      !isWithdrawing && availableBalance >= Withdrawal.minimumAmount;

  ReportState copyWith({
    ReportStatus? status,
    List<ReportTransaction>? transactions,
    DateTime? selectedMonth,
    ProviderBalance? balance,
    bool? isWithdrawing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      balance: balance ?? this.balance,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        selectedMonth,
        balance,
        isWithdrawing,
        errorMessage,
      ];
}
