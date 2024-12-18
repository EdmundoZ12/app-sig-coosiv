import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCorteService {
  final Dio dio = Dio();

  Future<void> registerWaterCutOff(int routeId, int accountId) async {
    try {
      // Obtener el token de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token no encontrado');
      }

      // Datos para el POST
      final data = {
        "routeId": routeId,
        "accountId": accountId,
      };

      // Realizar la solicitud HTTP
      final response = await dio.post(
        'https://sigcortes.runasp.net/api/ServiceCut/cut-service',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Manejar la respuesta
      if (response.statusCode == 200) {
        print('Corte de agua registrado exitosamente');
      } else {
        throw Exception('Error al registrar el corte de agua');
      }
    } catch (e) {
      print('Error registrando el corte de agua: $e');
      throw Exception('Failed to register water cut-off');
    }
  }
}
