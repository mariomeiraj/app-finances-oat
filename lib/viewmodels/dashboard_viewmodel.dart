import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_finances_oat/models/transaction_model.dart';
import 'package:app_finances_oat/viewmodels/transactions_viewmodel.dart';

class DashboardState {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final List<TransactionModel> recentTransactions;

  const DashboardState({
    this.totalBalance = 0.0,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.recentTransactions = const [],
  });
}

final dashboardStateProvider =
    Provider.family<DashboardState, int>((ref, userId) {
  final transactionsState = ref.watch(transactionsViewModelProvider(userId));
  final transactions = transactionsState.transactions;

  double totalIncome = 0.0;
  double totalExpenses = 0.0;

  for (final transaction in transactions) {
    if (transaction.type == TransactionType.income) {
      totalIncome += transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      totalExpenses += transaction.amount;
    }
  }

  final totalBalance = totalIncome - totalExpenses;

  final sorted = List<TransactionModel>.from(transactions)
    ..sort((a, b) => b.date.compareTo(a.date));
  final recentTransactions = sorted.take(5).toList();

  return DashboardState(
    totalBalance: totalBalance,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    recentTransactions: recentTransactions,
  );
});

final balanceVisibilityProvider = StateProvider<bool>((ref) => true);
