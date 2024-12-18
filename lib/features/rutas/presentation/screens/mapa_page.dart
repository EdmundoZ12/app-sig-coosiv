import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:app_coosiv/config/helpers/getRoutesPoint.dart';
import 'package:app_coosiv/config/helpers/postCorte.dart';
import 'package:app_coosiv/config/interfaces/datamodel.dart';
import 'package:app_coosiv/features/rutas/presentation/utils/constant.dart';
import 'package:app_coosiv/features/rutas/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

class MapScreen extends StatefulWidget {
  static const String routename = 'MapScreen';
  final DataModel route;
  final int idRoute;
  const MapScreen({super.key, required this.route, required this.idRoute});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> googleMapController = Completer();
  List<LatLng> posiciones = [];
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  CameraPosition initialCameraPosition = const CameraPosition(
    zoom: 16,
    target: LatLng(-16.37963957604066, -60.96070479275168),
  );
  late BitmapDescriptor icon;
  late BitmapDescriptor startIcon;
  late BitmapDescriptor corteIcon;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await setIcon();
    await setStartIcon();
    await setIconCortado();
    mostrarRutas(widget.route);
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(kMarker, 120);
    icon = BitmapDescriptor.fromBytes(iconBytes);
  }

  Future<void> setIconCortado() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(corteMarker, 120);
    corteIcon = BitmapDescriptor.fromBytes(iconBytes);
  }

  Future<void> setStartIcon() async {
    Uint8List startIconBytes = await Utils.getBytesFromAsset(
        startMarker, 120); // Usa el icono deseado para el punto de partida
    startIcon = BitmapDescriptor.fromBytes(startIconBytes);
  }

Future<Uint8List> crearMarcadorConNumero(int numero) async {
  const int marcadorTamao = 120;
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = Colors.red;
  final Paint bordePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  // Dibuja el círculo
  canvas.drawCircle(
    Offset(marcadorTamao / 2, marcadorTamao / 2),
    marcadorTamao / 2,
    paint,
  );

  // Dibuja el borde blanco
  canvas.drawCircle(
    Offset(marcadorTamao / 2, marcadorTamao / 2),
    marcadorTamao / 2,
    bordePaint,
  );

  // Dibuja el número en el centro
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: numero.toString(),
      style: TextStyle(
        fontSize: marcadorTamao / 2.5,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (marcadorTamao - textPainter.width) / 2,
      (marcadorTamao - textPainter.height) / 2,
    ),
  );

  final img = await pictureRecorder.endRecording().toImage(marcadorTamao, marcadorTamao);
  final ByteData? data = await img.toByteData(format: ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

Future<void> mostrarRutas(DataModel route) async {
  if (route.serviceAccounts.isNotEmpty) {
    LatLng startingPoint = LatLng(route.startingPoint.latitude, route.startingPoint.longitude);
    posiciones.add(startingPoint);

    // Primer marcador con imagen personalizada
    markers.add(
      Marker(
        markerId: MarkerId(startingPoint.toString()),
        position: startingPoint,
        icon: startIcon,
        infoWindow: InfoWindow(
          title: 'Punto Inicial',
          snippet: 'COOSIV LTDA',
        ),
      ),
    );

    int index = 1; // Inicia la enumeración
    for (var account in route.serviceAccounts) {
      LatLng accountLocation = LatLng(account.address.latitude, account.address.longitude);
      posiciones.add(accountLocation);

      // Generar marcador numerado
      Uint8List marcadorNumerado = await crearMarcadorConNumero(index);

      markers.add(
        Marker(
          markerId: MarkerId(accountLocation.toString()),
          position: accountLocation,
          icon: BitmapDescriptor.fromBytes(marcadorNumerado),
          onTap: () {
            mostrarDialogo(
              context,
              account.name,
              account.accountNumber,
              'N° cuenta: ${account.accountNumber}\nCategoría: ${account.category}\nNotas: ${account.notes}',
              MarkerId(accountLocation.toString()),
            );
          },
          infoWindow: InfoWindow(
            title: account.name,
            snippet: 'N° cuenta: ${account.accountNumber}, Categoría: ${account.category}\nNotas: ${account.notes}',
          ),
        ),
      );

      // Ruta entre los puntos
      List<LatLng> routePoints = await getRoutePoints(startingPoint, accountLocation);
      if (routePoints.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('${startingPoint.toString()}-${accountLocation.toString()}'),
            points: routePoints,
            width: 4,
            color: Colors.blue,
          ),
        );
      }

      startingPoint = accountLocation; // Actualiza para la siguiente iteración
      index++; // Incrementa el número del marcador
    }

    // Cierra el circuito conectando el último punto con el inicial
    LatLng lastPoint = posiciones.last;
    List<LatLng> closingRoute = await getRoutePoints(lastPoint, posiciones.first);
    if (closingRoute.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('closing-${lastPoint.toString()}-${posiciones.first.toString()}'),
          points: closingRoute,
          width: 4,
          color: Colors.red,
        ),
      );
    }

    setState(() {});
  }
}


  void mostrarDialogo(BuildContext context, String titulo, int accountId,
      String contenido, MarkerId markerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.transparent, // Hace que el fondo sea transparente
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent, // Fondo celeste
              borderRadius: BorderRadius.circular(15), // Bordes redondeados
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5), // Sombra debajo del cuadro
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texto en blanco
                  ),
                ),
                const SizedBox(
                    height: 15), // Espacio entre el título y contenido
                Text(
                  contenido,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black, // Color de texto blanco suave
                  ),
                ),
                const SizedBox(height: 20), // Espacio entre contenido y botón
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    backgroundColor: Colors.white, // Botón blanco
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bordes redondeados
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Colors.blueAccent, // Texto azul del botón
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                    height: 10), // Espacio entre contenido y nuevo botón
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    backgroundColor: Colors.green, // Botón verde
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bordes redondeados
                    ),
                  ),
                  onPressed: () {
                    // Obtén el marcador que deseas registrar
                    Marker marcadorCorrecto = markers
                        .firstWhere((marker) => marker.markerId == markerId);

                    registrarCorte(marcadorCorrecto,
                        accountId); // Llama a la función para registrar el corte pasando el MarkerId
                  },
                  child: const Text(
                    'Registrar Corte',
                    style: TextStyle(
                      color: Colors.white, // Texto blanco del botón
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void registrarCorte(Marker marcadorCorte, int accountId) async {
    try {
      // Llama al servicio para registrar el corte
      final routeId = widget.idRoute; // Id de la ruta
      await PostCorteService().registerWaterCutOff(routeId, accountId);

      // Actualiza los datos del marcador en el set
      actualizarImagen(marcadorCorte);

      // Cierra el diálogo
      Navigator.of(context).pop();
    } catch (e) {
      print('Error registrando el corte: $e');
      // Muestra un mensaje de error si es necesario
    }
  }

  void actualizarImagen(Marker marcadorCorte) async {
    // Cambia el icono del marcador a la imagen de "corte"
    marcadorCorte = await marcadorCorte.copyWith(
    iconParam: corteIcon, // O el nuevo icono que desees usar
    );

    // Actualiza los datos del marcador en el set
      markers.removeWhere((marker) => marker.markerId == marcadorCorte.markerId);
    markers.add(marcadorCorte);

    // Refresca el estado del mapa
    setState(() {});
  }

  void setPolylines() {
    if (posiciones.length > 1) {
      polylines.clear(); // Limpiar los polylines actuales
      polylines.add(
        Polyline(
          polylineId: const PolylineId('id'),
          points: posiciones,
          width: 4,
          color: Colors.purple,
        ),
      );
      moverCamara(posiciones.last);
      setState(() {});
    }
  }

  Future<void> moverCamara(LatLng posicion) async {
    final controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(posicion, 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Google Maps'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/'); // Redirigir a la pantalla de rutas
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                markers: markers,
                polylines: polylines,
                mapType: MapType.normal,
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  googleMapController.complete(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
