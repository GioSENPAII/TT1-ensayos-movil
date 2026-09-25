// Flujo de entrega de ensayo de punta a punta (CU-ALU-02, CU-ALU-03, CU-ALU-04) contra el backend
// LOCAL con el motor de IA simulado y la BD recién sembrada:
//   (ensayos-backend) docker compose down -v && docker compose up -d && MAIL_ENABLED=false ./run-local.sh
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/flujo_entrega_test.dart -d <simulador>
import 'dart:typed_data';

import 'package:ensayos_movil/main.dart' as app;
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/fake_file_picker.dart';
import 'helpers/pdf_de_prueba.dart';

Future<void> esperar(WidgetTester t, Finder f, {int segundos = 20}) async {
  final fin = DateTime.now().add(Duration(seconds: segundos));
  while (DateTime.now().isBefore(fin)) {
    await t.pump(const Duration(milliseconds: 100));
    if (f.evaluate().isNotEmpty) return;
  }
  throw TestFailure('No apareció: $f');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> captura(WidgetTester t, String nombre) async {
    await t.pump(const Duration(milliseconds: 500));
    await binding.takeScreenshot(nombre);
  }

  testWidgets('entregar un ensayo, ver el reporte y el historial', (t) async {
    final picker = FilePickerFalso([
      ArchivoFalso('ensayo_enorme.pdf', Uint8List(11 * 1024 * 1024)),
      ArchivoFalso('3CM1_Alumno_Prueba_Ensayo1.pdf', pdfConTexto([
        'Evolucion de los Sistemas Operativos',
        'Introduccion',
        'Un sistema operativo administra los recursos de hardware y software.',
        'Desarrollo',
        'Los primeros sistemas por lotes dieron paso a la multiprogramacion y al tiempo compartido.',
        'Conclusiones',
        'Los sistemas operativos modernos equilibran rendimiento, seguridad y usabilidad.',
        'Referencias',
        '[1] A. Silberschatz, Operating System Concepts, 10th ed. Wiley, 2018.',
      ])),
    ]);
    FilePickerPlatform.instance = picker;
    await const FlutterSecureStorage().deleteAll();
    await binding.convertFlutterSurfaceToImage();
    app.main();

    await esperar(t, find.text('Iniciar sesión'));
    await t.enterText(find.byType(TextFormField).at(0), 'alumno.prueba@alumno.ipn.mx');
    await t.enterText(find.byType(TextFormField).at(1), 'Prueba123');
    await t.tap(find.text('Iniciar sesión'));

    // Inicio → detalle de la tarea pendiente
    await esperar(t, find.text('Tareas pendientes'));
    await t.tap(find.text('Ensayo Unidad 1'));
    await esperar(t, find.text('Subir archivo'));
    await captura(t, '10_detalle_tarea');

    // Archivo de más de 10 MB: se rechaza en el cliente (CU-ALU-02 E2)
    await t.tap(find.text('Subir archivo'));
    await esperar(t, find.textContaining('supera el límite de 10 MB'));
    await captura(t, '11_archivo_muy_grande');
    expect(picker.extensionesPedidas.first, ['pdf']);
    await t.pump(const Duration(seconds: 5)); // deja que desaparezca el SnackBar

    // PDF válido → confirmación → envío
    await t.tap(find.text('Subir archivo'));
    await esperar(t, find.text('Confirmar envío'));
    await captura(t, '12_confirmar_envio');
    await t.tap(find.text('Enviar ensayo'));
    await esperar(t, find.text('Archivo recibido, procesando calificación...'));
    await captura(t, '13_procesando');

    // Reporte (CU-ALU-03)
    await esperar(t, find.text('Desglose por criterio'));
    await captura(t, '14_reporte');
    await t.tap(find.text('Desarrollo'));
    await t.pumpAndSettle();
    await t.drag(find.byType(ListView).last, const Offset(0, -500));
    await t.pumpAndSettle();
    await captura(t, '15_reporte_criterios');

    // El detalle ahora ofrece el reporte y ya no permite reemplazar (RN-WEB-04)
    await t.pageBack();
    await esperar(t, find.text('Ver reporte de calificación'));
    expect(find.text('Subir archivo'), findsNothing);
    await captura(t, '16_detalle_calificada');
    await t.pageBack();
    await t.pumpAndSettle();

    // Historial (CU-ALU-04) e Inicio con la última calificación
    await t.tap(find.text('Entregas'));
    await esperar(t, find.text('3CM1_Alumno_Prueba_Ensayo1.pdf'));
    await captura(t, '17_historial');
    await t.tap(find.text('Inicio'));
    await esperar(t, find.text('Última calificación'));
    await captura(t, '18_inicio_ultima_calificacion');
  });
}
