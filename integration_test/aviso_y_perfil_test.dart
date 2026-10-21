// Aviso de privacidad en el registro y foto de perfil, contra el backend LOCAL (db/seed_local.sql).
// Requiere: docker compose up -d  y  ./run-local.sh  (en ensayos-backend/)
// Ejecutar:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/aviso_y_perfil_test.dart -d <simulador>
// Elegir la imagen abre el selector del sistema, que la prueba no puede manejar: aquí solo se
// revisan las opciones (galería y Archivos, sin cámara).
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

  testWidgets('registro exige el aviso de privacidad; perfil con foto', (t) async {
    await const FlutterSecureStorage().deleteAll();
    await binding.convertFlutterSurfaceToImage();
    app.main();

    // Registro: sin aceptar el aviso no se envían los datos
    await esperar(t, find.text('Iniciar sesión'));
    await t.tap(find.textContaining('Regístrate'));
    await esperar(t, find.text('Datos de registro'));
    await t.enterText(find.byType(TextFormField).at(0), 'Ana');
    await t.enterText(find.byType(TextFormField).at(1), 'Prueba');
    await t.enterText(find.byType(TextFormField).at(2), 'ana.e2e@alumno.ipn.mx');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.tap(find.text('Continuar'));
    await esperar(t, find.text('Debes aceptar el aviso de privacidad para continuar'));
    await captura(t, '20_registro_sin_aviso');

    // El aviso se abre desde el enlace
    await t.tap(find.text('aviso de privacidad'));
    await esperar(t, find.text('Aviso de privacidad integral'));
    await captura(t, '21_aviso');
    await t.pageBack();
    await esperar(t, find.text('Datos de registro'));
    await t.tap(find.byType(Checkbox));
    await t.pump();
    expect(find.text('Debes aceptar el aviso de privacidad para continuar'), findsNothing);
    await captura(t, '22_registro_con_aviso');
    await t.pageBack();

    // Perfil con la foto que ya tiene el alumno de prueba
    await esperar(t, find.text('Iniciar sesión'));
    await t.enterText(find.byType(TextFormField).at(0), 'alumno.prueba@alumno.ipn.mx');
    await t.enterText(find.byType(TextFormField).at(1), 'Prueba123');
    await t.tap(find.text('Iniciar sesión'));
    await esperar(t, find.text('Hola, Alumno'));
    await t.tap(find.text('Perfil'));
    await esperar(t, find.text('Aviso de privacidad'));
    await captura(t, '23_perfil');

    await t.tap(find.bySemanticsLabel('Cambiar foto de perfil'));
    await esperar(t, find.text('Elegir de la galería'));
    expect(find.text('Elegir de Archivos'), findsOneWidget);
    expect(find.textContaining('cámara', findRichText: true), findsNothing);
    await captura(t, '24_opciones_foto');
  });
}
