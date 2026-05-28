import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_finances_oat/data/repositories/currency_repository.dart';
import 'package:app_finances_oat/models/currency_model.dart';

class CurrencyState {
  final List<CurrencyModel> currencies;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const CurrencyState({
    this.currencies = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastUpdated,
  });

  CurrencyState copyWith({
    List<CurrencyModel>? currencies,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return CurrencyState(
      currencies: currencies ?? this.currencies,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class CurrencyViewModel extends StateNotifier<CurrencyState> {
  final CurrencyRepository _repository;

  CurrencyViewModel(this._repository) : super(const CurrencyState());

  Future<void> fetchRates() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currencies = await _repository.fetchRates();
      state = state.copyWith(
        currencies: currencies,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao buscar cotações. Verifique sua conexão.',
      );
    }
  }
}

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepository();
});

final currencyViewModelProvider =
    StateNotifierProvider<CurrencyViewModel, CurrencyState>((ref) {
  final repository = ref.watch(currencyRepositoryProvider);
  return CurrencyViewModel(repository);
});
