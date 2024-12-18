import 'package:app_coosiv/config/helpers/getRoute.dart';
import 'package:app_coosiv/config/helpers/getRoutes.dart';
import 'package:app_coosiv/config/interfaces/dataListmodel.dart';
import 'package:app_coosiv/config/interfaces/datamodel.dart';
import 'package:app_coosiv/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RutasScreen extends StatefulWidget {
  const RutasScreen({Key? key}) : super(key: key);

  @override
  _RutasScreenState createState() => _RutasScreenState();
}

class _RutasScreenState extends State<RutasScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GetRoutesService _getRoutesService = GetRoutesService();
  final GetRouteService _getRouteService = GetRouteService();

  List<DataListModel> _routes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    try {
      final fetchedRoutes = await _getRoutesService.getRoutes();
      setState(() {
        _routes = fetchedRoutes;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Error al cargar las rutas: $error';
        _isLoading = false;
      });
    }
  }

  void _onRouteTapped(BuildContext context, int routeId) async {
    try {
      DataModel route = await _getRouteService.getRoute(routeId);
      if (route != null) {
        context.go('/mapa', extra: {
          'route': route,
          'routeId': routeId,
        }); // Redirigir a MapScreen con las rutas
      }
    } catch (error) {
      print('Error al cargar la ruta: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Rutas'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.directions_car),
          ),
        ],
      ),
      body: Theme(
        data: ThemeData(
          primaryColor: Colors.blue, // Color principal para la appBar
          scaffoldBackgroundColor: Colors.white, // Color de fondo
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0), // Espaciado interno
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      final route = _routes[index];
                      return Card(
                        color: Colors.lightBlueAccent,
                        elevation: 4, // Elevación para dar profundidad al card
                        margin: const EdgeInsets.symmetric(
                            vertical: 4), // Margen vertical
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                              16.0), // Padding interno del ListTile
                          leading: Icon(Icons.map,
                              color: Colors.black), // Icono a la izquierda
                          title: Text(
                            route.name,
                            style: const TextStyle(
                              fontSize: 18, // Tamaño de la fuente
                              fontWeight: FontWeight.bold, // Negrita
                            ),
                          ),
                          subtitle: Text('ID: ${route.id}'),
                          trailing: ElevatedButton(
                            onPressed: () => _onRouteTapped(context, route.id),
                            child:
                                const Text('Ver ruta'), // Botón para ver ruta
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
