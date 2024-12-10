import 'package:app_coosiv/features/auth/domain/domain.dart';
import '../infrastructure.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl({AuthDatasource? datasource})
      : datasource = datasource ?? AuthDatasourceImpl();
  @override
  Future<User> chechAuthStatus(String token) {
    return datasource.chechAuthStatus(token);
  }

  @override
  Future<User> login(String username, String password) {
    return datasource.login(username, password);
  }

  @override
  Future<User> register(String username, String password, String fullName) {
    return datasource.register(username, password, fullName);
  }
}
