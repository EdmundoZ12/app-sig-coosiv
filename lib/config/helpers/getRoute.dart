import 'package:app_coosiv/config/interfaces/datamodel.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetRouteService {
  final Dio dio = Dio();

  Future<DataModel> getRoute(int id) async {
    try {
      // Obtener el token de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token no encontrado');
      }

      // Realizar la solicitud HTTP
      final response = await dio.get(
        'https://sigcortes.runasp.net/api/Routes/get-route/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Manejar la respuesta
      if (response.statusCode == 200) {
        print(response.statusCode);
        final dynamic routeJson = response.data;
        print(routeJson);
        final DataModel route = DataModel.fromJson(routeJson);
        print(route);
        return route;
      } else {
        throw Exception('Failed to load route');
      }
    } catch (e) {
      print('Error fetching route: $e');
      throw Exception('Failed to load route');
    }
  }
}
