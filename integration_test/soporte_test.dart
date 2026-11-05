// Pantalla de Soporte desde el inicio de sesión y el perfil, contra el backend LOCAL (db/seed_local.sql).
// Requiere: docker compose up -d  y  ./run-local.sh  (en ensayos-backend/)
// Ejecutar:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/soporte_test.dart -d <simulador>
import 'package:ensayos_movil/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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

  testWidgets('Soporte se abre desde el inicio de sesión y desde el perfil', (t) async {
    await const FlutterSecureStorage().deleteAll();
    await binding.convertFlutterSurfaceToImage();
    app.main();

    // Desde el inicio de sesión, sin cuenta
    await esperar(t, find.text('Iniciar sesión'));
    await captura(t, '28_login_con_soporte');
    await t.tap(find.text('¿Necesitas ayuda? Soporte'));
    await esperar(t, find.text('Cuenta y acceso'));
    await captura(t, '29_soporte_desde_login');
    await t.pageBack();

    await esperar(t, find.text('Iniciar sesión'));
    await t.enterText(find.byType(TextFormField).at(0), 'alumno.prueba@alumno.ipn.mx');
    await t.enterText(find.byType(TextFormField).at(1), 'Prueba123');
    await t.tap(find.text('Iniciar sesión'));
    await esperar(t, find.text('Hola, Alumno'));
    await t.tap(find.text('Perfil'));
    await esperar(t, find.text('Soporte'));
    await captura(t, '30_perfil_con_soporte');

    await t.tap(find.text('Soporte'));
    await esperar(t, find.text('Cuenta y acceso'));
    // Sin la sección de profesores: la app es solo para alumnos
    expect(find.text('Profesores'), findsNothing);
    await captura(t, '31_soporte');

    await t.tap(find.text('¿Qué contraseña puedo usar?'));
    await t.pumpAndSettle();
    expect(find.textContaining('carácter especial', findRichText: true), findsOneWidget);
    await captura(t, '32_soporte_pregunta_abierta');

    await t.scrollUntilVisible(find.text('¿No encontraste tu respuesta?'), 400,
        scrollable: find.byType(Scrollable).first);
    // Los tres administradores (RN-AUTH-05) aparecen como contacto
    await t.drag(find.byType(Scrollable).last, const Offset(0, -600));
    await t.pumpAndSettle();
    for (final correo in ['porraszuniga@gmail.com', 'joseeduardomayafabela@gmail.com', 'glongoria.3a.is@gmail.com']) {
      expect(find.text(correo), findsOneWidget);
    }
    await captura(t, '33_soporte_contacto');
  });
}
