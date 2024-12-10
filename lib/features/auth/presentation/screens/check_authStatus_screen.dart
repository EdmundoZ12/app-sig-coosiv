import 'package:app_coosiv/features/auth/presentation/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CheckAuthstatusScreen extends ConsumerWidget {
  const CheckAuthstatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.listen(authProvider, (previous, next) {
    //   if (next.authStatus == AuthStatus.authenticated) {
    //     context
    //         .go('/'); // Redirigir a la ruta principal o a la pantalla deseada.
    //   }
    // });
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}
