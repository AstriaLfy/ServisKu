import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/ui/features/provider/report/data/report_repository.dart';
import 'package:servis_ku/ui/features/provider/report/domain/report_models.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _repository;

  ReportCubit({ReportRepository? repository})
      : _repository = repository ?? ReportRepository(),
        super(ReportState.initial());

  Future<void> load() async {
    if (state.status != ReportStatus.loaded) {
      emit(state.copyWith(status: ReportStatus.loading, clearError: true));
    }

    try {
      final transactions = await _repository.getCompletedTransactions();
      final balance = await _repository.getBalance();
      emit(ReportState(
        status: ReportStatus.loaded,
        transactions: transactions,
        selectedMonth: state.selectedMonth,
        balance: balance,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.status == ReportStatus.loaded
            ? ReportStatus.loaded
            : ReportStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void selectMonth(DateTime month) {
    emit(state.copyWith(selectedMonth: DateTime(month.year, month.month)));
  }

  Future<Withdrawal?> withdraw() async {
    if (!state.canWithdraw) return null;
    emit(state.copyWith(isWithdrawing: true, clearError: true));

    try {
      final withdrawal = await _repository.requestWithdrawal();
      final balance = await _repository.getBalance();
      emit(state.copyWith(isWithdrawing: false, balance: balance));
      return withdrawal;
    } catch (e) {
      emit(state.copyWith(isWithdrawing: false, errorMessage: e.toString()));
      return null;
    }
  }
}
