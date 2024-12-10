import 'package:app_coosiv/features/auth/domain/domain.dart';
import 'package:app_coosiv/features/auth/infrastructure/infrastructure.dart';
import 'package:app_coosiv/features/shared/infrastructure/services/key_value_storage.dart';
import 'package:app_coosiv/features/shared/infrastructure/services/key_value_storage_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorage = KeyValueStorageImpl();

  return AuthNotifier(
      authRepository: authRepository, keyValueStorage: keyValueStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final KeyValueStorage keyValueStorage;

  final AuthRepository authRepository;

  AuthNotifier({required this.authRepository, required this.keyValueStorage})
      : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> loginUser(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = await authRepository.login(username, password);
      _setLoggerdUser(user);
    } on CustomError catch (e) {
      logout(e.message);
    } catch (e) {
      logout('Error no controlado');
    }
  }

  void registerUser(String username, String password) async {}

  Future<void> checkAuthStatus() async {
    final token = await keyValueStorage.getValue<String>('token');
    if (token == null) {
      return logout();
    }
    try {
      final user = await authRepository.chechAuthStatus(token);
      _setLoggerdUser(
          user); // Aquí se debe ajustar para manejar el estado del usuario
    } catch (e) {
      logout();
    }
  }

  void _setLoggerdUser(User user) async {
    await keyValueStorage.setKeyValue('token', user.authToken);
    state = state.copyWhith(
        user: user, authStatus: AuthStatus.authenticated, errorMessage: '');
  }

  Future<void> logout([String? errorMessage]) async {
    await keyValueStorage.removeKeyValue('token');
    state = state.copyWhith(
        authStatus: AuthStatus.noAuthenticated,
        user: null,
        errorMessage: errorMessage);
  }
}

enum AuthStatus { checking, authenticated, noAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState(
      {this.authStatus = AuthStatus.checking,
      this.user,
      this.errorMessage = ''});

  AuthState copyWhith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
  }) =>
      AuthState(
          authStatus: authStatus ?? this.authStatus,
          user: user ?? this.user,
          errorMessage: errorMessage ?? this.errorMessage);
}
