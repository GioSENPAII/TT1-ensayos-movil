// Prueba de punta a punta contra el backend LOCAL con los datos de db/seed_local.sql.
// Requiere: docker compose up -d  y  ./run-local.sh  (en ensayos-backend/)
// Ejecutar:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/flujo_alumno_test.dart -d <simulador>
// Las capturas quedan en build/capturas/.
import 'package:ensayos_movil/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// pumpAndSettle no termina mientras gira un indicador de carga: se espera al widget buscado.
Future<void> esperar(WidgetTester t, Finder f, {int segundos = 15}) async {
  final fin = DateTime.now().add(Duration(seconds: segundos));
  while (DateTime.now().isBefore(fin)) {
    await t.pump(const Duration(milliseconds: 200));
    if (f.evaluate().isNotEmpty) return;
  }
  throw TestFailure('No apareció: $f');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> captura(WidgetTester t, String nombre) async {
    await t.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot(nombre);
  }

  testWidgets('flujo del alumno: login, inicio, grupos, unirse, perfil y logout', (t) async {
    await const FlutterSecureStorage().deleteAll();
    await binding.convertFlutterSurfaceToImage();
    app.main();

    // Login
    await esperar(t, find.text('Iniciar sesión'));
    await captura(t, '01_login');
    await t.enterText(find.byType(TextFormField).at(0), 'alumno.prueba@alumno.ipn.mx');
    await t.enterText(find.byType(TextFormField).at(1), 'Prueba123');
    await t.tap(find.text('Iniciar sesión'));

    // Inicio
    await esperar(t, find.text('Hola, Alumno'));
    await esperar(t, find.text('Tareas pendientes'));
    await captura(t, '02_inicio');
    expect(find.text('Ensayo Unidad 1'), findsOneWidget);

    // Mis grupos
    await t.tap(find.text('Ver todos'));
    await esperar(t, find.text('Mis grupos'));
    await t.tap(find.text('Sistemas Operativos 3CM1').last);
    await esperar(t, find.text('Ensayo Diagnóstico'));
    await captura(t, '03_mis_grupos');

    // Unirse a un grupo: inactivo y código inexistente (CU-ALU-01 E1, E2)
    await t.tap(find.text('Unirse a un grupo').last);
    await esperar(t, find.text('Unirme'));
    await t.enterText(find.byType(TextFormField), 'so3cm2');
    await t.tap(find.text('Unirme'));
    await esperar(t, find.text('Este grupo ya no acepta nuevos integrantes'));
    await captura(t, '04_unirse_inactivo');
    // Como una persona: tocar el campo (el envío anterior cerró el teclado) y escribir
    await t.tap(find.byType(TextFormField));
    await t.pump(const Duration(milliseconds: 500));
    await t.enterText(find.byType(TextFormField), 'SO3CM1');
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('SO3CM1'), findsOneWidget);
    await t.tap(find.text('Unirme'));
    await esperar(t, find.text('Ya eres parte de este grupo'));
    await t.pageBack();
    await t.pumpAndSettle();
    await t.pageBack();
    await t.pumpAndSettle();

    // Perfil y cierre de sesión
    await t.tap(find.text('Perfil'));
    await esperar(t, find.text('alumno.prueba@alumno.ipn.mx'));
    await captura(t, '05_perfil');
    await t.tap(find.widgetWithText(OutlinedButton, 'Cerrar sesión'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(TextButton, 'Cerrar sesión'));
    await esperar(t, find.text('Iniciar sesión'));

    // Un profesor no puede entrar a la app móvil (Tabla 18)
    await t.enterText(find.byType(TextFormField).at(0), 'profesor.prueba@ipn.mx');
    await t.enterText(find.byType(TextFormField).at(1), 'Prueba123');
    await t.tap(find.text('Iniciar sesión'));
    await esperar(t, find.textContaining('exclusiva para alumnos'));
    await captura(t, '06_profesor_rechazado');
  });
}
