import 'package:app_coosiv/config/interfaces/datamodel.dart';
import 'package:app_coosiv/config/router/app_router_notifier.dart';
import 'package:app_coosiv/features/auth/presentation/provider/auth_provider.dart';
import 'package:app_coosiv/features/auth/presentation/screens/check_authStatus_screen.dart';
import 'package:app_coosiv/features/auth/presentation/screens/login_screen.dart';
import 'package:app_coosiv/features/auth/presentation/screens/register_screen.dart';
import 'package:app_coosiv/features/rutas/presentation/screens/mapa_page.dart';
import 'package:app_coosiv/features/rutas/presentation/screens/rutas_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: goRouterNotifier,
    routes: [
      ///* Primera pantalla
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthstatusScreen(),
      ),

      ///* Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      ///* Product Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const RutasScreen(),
      ),
      GoRoute(
        path: '/mapa',
        builder: (context, state) {
          final Map<String, dynamic> arguments =
              state.extra as Map<String, dynamic>;
          final DataModel route = arguments['route'];
          final int routeId = arguments['routeId'];
          return MapScreen(
              route: route, idRoute: routeId); // Pasa el argumento a MapScreen
        },
      ),
    ],
    redirect: (context, state) {
      final authStatus = goRouterNotifier.authStatus;
      final isGoingTo = state.matchedLocation;

      if (isGoingTo == '/splash' && authStatus == AuthStatus.checking)
        return null;

      if (authStatus == AuthStatus.noAuthenticated) {
        if (isGoingTo == '/login' || isGoingTo == '/register') return null;

        return '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/splash') {
          return '/';
        }
      }

      return null;
    },
  );
});
