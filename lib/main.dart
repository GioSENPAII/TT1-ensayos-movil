import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  Intl.defaultLocale = 'es_MX';
  setupInjector();
  runApp(const EnsayosApp());
}

class EnsayosApp extends StatefulWidget {
  const EnsayosApp({super.key});

  @override
  State<EnsayosApp> createState() => _EnsayosAppState();
}

class _EnsayosAppState extends State<EnsayosApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(AppStarted()),
      // AuthGate (sección 4.6.2): el estado de sesión decide qué árbol se muestra
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (_, s) => s is AuthAuthenticated || s is AuthUnauthenticated,
        listener: (context, state) {
          final nav = _navigatorKey.currentState!;
          if (state is AuthAuthenticated) {
            nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
          } else if (state is AuthUnauthenticated) {
            nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            if (state.message != null) {
              _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(state.message!)));
            }
          }
        },
        child: MaterialApp(
          title: 'Ensayos ESCOM',
          theme: AppTheme.theme,
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          scaffoldMessengerKey: _messengerKey,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
