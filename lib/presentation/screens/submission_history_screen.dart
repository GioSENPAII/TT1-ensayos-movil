import 'package:flutter/material.dart';

import '../widgets/mensaje_vacio.dart';

/// Historial de entregas (SubmissionHistoryScreen, CU-ALU-04).
/// Se completa en el paso 3 junto con la carga de ensayos y el reporte de calificación.
class SubmissionHistoryScreen extends StatelessWidget {
  const SubmissionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis entregas'), automaticallyImplyLeading: false),
      body: const Center(
        child: MensajeVacio(
          icono: Icons.assignment_outlined,
          titulo: 'Aún no has enviado ningún ensayo',
          detalle: 'Aquí aparecerán tus entregas y sus calificaciones.',
        ),
      ),
    );
  }
}
