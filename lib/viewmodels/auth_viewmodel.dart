import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_finances_oat/data/local/app_database.dart';
import 'package:app_finances_oat/data/repositories/auth_repository.dart';
import 'package:app_finances_oat/models/user_model.dart';

class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  User? get user => currentUser;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authRepository.loginUser(email, password);

      if (user != null) {
        state = state.copyWith(
          currentUser: user,
          isLoading: false,
          isAuthenticated: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'E-mail ou senha inválidos.',
          isAuthenticated: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao realizar login. Tente novamente.',
        isAuthenticated: false,
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final newUser = User(name: name, email: email, password: password);
      final registeredUser = await _authRepository.registerUser(newUser);
      state = state.copyWith(
        currentUser: registeredUser,
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> updateUser(String name, String email, String password) async {
    if (state.currentUser == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedUser = state.currentUser!.copyWith(
        name: name,
        email: email,
        password: password,
      );
      final savedUser = await _authRepository.updateUser(updatedUser);
      state = state.copyWith(
        currentUser: savedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void logout() {
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return AuthRepository(database);
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});
