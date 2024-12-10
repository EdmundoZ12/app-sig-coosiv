import 'package:app_coosiv/config/config.dart';
import 'package:app_coosiv/features/auth/domain/domain.dart';
import 'package:app_coosiv/features/auth/infrastructure/infrastructure.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));

  @override
  Future<User> chechAuthStatus(String token) async {
    // Verifica si el token es válido
    if (JwtDecoder.isExpired(token)) {
      throw CustomError('El token ha expirado');
    }

    try {
      // Decodifica el token y recupera información adicional si es necesario
      final Map<dynamic, dynamic> decodedToken = JwtDecoder.decode(token);

      final int id = int.parse(decodedToken['id']); // Convertir String a int
      final String username = decodedToken['username'];
      final String authToken =
          token; // Esto debería venir ya como String o lo recibirías de otro lugar

      if (id == null) {
        throw CustomError('ID del usuario no encontrado en el token');
      }
      if (username == null) {
        throw CustomError('Nombre de usuario no encontrado en el token');
      }

      // Retorna un usuario con los datos del token
      final user = User(
        id: id,
        username: username,
        authToken: authToken,
      );
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw CustomError('Token Incorrecto');
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await dio.post('/auth/login',
          data: {'username': username, 'password': password});
      final user = UserMapper.userJsonToEntity(response.data);

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw CustomError(
            e.response?.data['message'] ?? 'Credenciales incorrectas');
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<User> register(String username, String password, String fullName) {
    // TODO: implement register
    throw UnimplementedError();
  }
}
