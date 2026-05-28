import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_finances_oat/data/repositories/transaction_repository.dart';
import 'package:app_finances_oat/models/transaction_model.dart';
import 'package:app_finances_oat/viewmodels/auth_viewmodel.dart';

class TransactionsState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class TransactionsViewModel extends StateNotifier<TransactionsState> {
  final TransactionRepository _repository;
  final int _userId;

  TransactionsViewModel(this._repository, this._userId)
      : super(const TransactionsState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final transactions =
          await _repository.getTransactions(_userId);
      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar transações.',
      );
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      await _repository.addTransaction(transaction);
      await loadTransactions();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Transação adicionada com sucesso!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao adicionar transação.',
      );
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      await _repository.updateTransaction(transaction);
      await loadTransactions();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Transação atualizada com sucesso!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar transação.',
      );
    }
  }

  Future<void> deleteTransaction(int id) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      await _repository.deleteTransaction(id);
      await loadTransactions();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Transação excluída com sucesso!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao excluir transação.',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return TransactionRepository(database);
});

final transactionsViewModelProvider = StateNotifierProvider.family<
    TransactionsViewModel, TransactionsState, int>((ref, userId) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionsViewModel(repository, userId);
});
