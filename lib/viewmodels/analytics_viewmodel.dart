import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_finances_oat/viewmodels/transactions_viewmodel.dart';
import 'package:app_finances_oat/models/transaction_model.dart';

class AnalyticsData {
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeByCategory;
  final double totalIncome;
  final double totalExpenses;

  const AnalyticsData({
    this.expensesByCategory = const {},
    this.incomeByCategory = const {},
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
  });
}

final analyticsDataProvider =
    Provider.family<AnalyticsData, int>((ref, userId) {
  final transactionsState = ref.watch(transactionsViewModelProvider(userId));
  final transactions = transactionsState.transactions;

  final Map<String, double> expensesByCategory = {};
  final Map<String, double> incomeByCategory = {};
  double totalIncome = 0.0;
  double totalExpenses = 0.0;

  for (final transaction in transactions) {
    final category = transaction.category;
    final amount = transaction.amount;

    if (transaction.type == TransactionType.expense) {
      totalExpenses += amount;
      expensesByCategory[category] =
          (expensesByCategory[category] ?? 0.0) + amount;
    } else if (transaction.type == TransactionType.income) {
      totalIncome += amount;
      incomeByCategory[category] =
          (incomeByCategory[category] ?? 0.0) + amount;
    }
  }

  return AnalyticsData(
    expensesByCategory: expensesByCategory,
    incomeByCategory: incomeByCategory,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
  );
});
