import 'package:app_coosiv/config/interfaces/dataListmodel.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetRoutesService {
  final Dio dio = Dio();

  Future<List<DataListModel>> getRoutes() async {
    try {
      // Obtener el token de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token no encontrado');
      }

      // Realizar la solicitud HTTP
      final response = await dio.get(
        'https://sigcortes.runasp.net/api/Routes/get-routes',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Manejar la respuesta
      if (response.statusCode == 200) {
        final List<dynamic> routesJson = response.data;
        List<DataListModel> routes =
            routesJson.map((json) => DataListModel.fromJson(json)).toList();
        return routes;
      } else {
        throw Exception('Failed to load routes');
      }
    } catch (e) {
      print('Error fetching routes: $e');
      throw Exception('Failed to load routes');
    }
  }
}
