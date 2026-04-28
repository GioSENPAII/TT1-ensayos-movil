import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'login_screen.dart';

class HomePlaceholderScreen extends StatelessWidget {
  final String nombre;
  final String correo;

  const HomePlaceholderScreen({
    super.key,
    required this.nombre,
    required this.correo,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inicio'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () =>
                  context.read<AuthBloc>().add(LogoutRequested()),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 72, color: AppTheme.guinda),
                const SizedBox(height: 16),
                Text(
                  '¡Bienvenido, $nombre!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.guinda,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  correo,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.grisInactivo),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Módulo de ensayos próximamente.',
                  style: TextStyle(color: AppTheme.grisInactivo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
