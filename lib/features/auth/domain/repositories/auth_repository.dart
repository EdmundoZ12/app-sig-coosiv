import 'package:app_coosiv/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<User> register(String username, String password, String fullName);
  Future<User> chechAuthStatus(String token);
}
