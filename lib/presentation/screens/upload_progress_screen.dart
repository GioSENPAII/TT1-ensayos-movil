import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../bloc/grading/grading_bloc.dart';
import '../bloc/grading/grading_event.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_event.dart';
import '../bloc/submission/submission_bloc.dart';
import '../bloc/submission/submission_event.dart';
import '../bloc/submission/submission_state.dart';
import '../navigation/navegacion.dart';
import '../widgets/mensaje_vacio.dart';

/// Procesamiento del envío (UploadProgressScreen, CU-ALU-02 pasos 6-7). Mientras se sube el archivo
/// no se permite regresar (sección 4.6.4). En cuanto el servidor lo recibe, el alumno puede salir:
/// la calificación continúa en el servidor y aparecerá en su historial (RNF-09).
class UploadProgressScreen extends StatelessWidget {
  final int tareaId;
  const UploadProgressScreen({super.key, required this.tareaId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubmissionBloc, SubmissionState>(
      listener: (context, state) {
        if (state is Procesando && !state.lento && !state.sinConexion) {
          // Recibido: la tarea ya aparece "En revisión" en Inicio, Mis grupos y el historial
          context.read<GroupBloc>().add(GroupsRequested());
          context.read<GradingBloc>().add(HistorialRequested());
        }
        if (state is EnvioTerminado) {
          context.read<GroupBloc>().add(GroupsRequested());
          context.read<GradingBloc>().add(HistorialRequested());
          if (state.entrega.calificada) {
            context.read<SubmissionBloc>().add(ArchivoDescartado());
            abrirReporte(context, state.entrega.id, reemplazar: true);
          }
        }
      },
      builder: (context, state) {
        // Solo se bloquea el regreso mientras el archivo viaja al servidor
        final enviando = state is Enviando || state is ArchivoListo;
        return PopScope(
          canPop: !enviando,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Envío de ensayo'),
              automaticallyImplyLeading: !enviando,
            ),
            body: Center(
              child: switch (state) {
                EnvioFallido(:final mensaje, :final esDeRed) => MensajeVacio(
                    icono: esDeRed ? Icons.wifi_off_outlined : Icons.error_outline,
                    titulo: 'No se pudo enviar tu ensayo',
                    detalle: mensaje,
                    textoBoton: 'Reintentar',
                    onPressed: () => context.read<SubmissionBloc>().add(EnvioConfirmado(tareaId)),
                  ),
                EnvioTerminado(:final entrega) when !entrega.calificada => MensajeVacio(
                    icono: Icons.error_outline,
                    titulo: 'Tu ensayo se recibió, pero no pudo calificarse',
                    detalle: entrega.mensaje,
                    textoBoton: 'Volver a la tarea',
                    onPressed: () {
                      context.read<SubmissionBloc>().add(ArchivoDescartado());
                      Navigator.of(context).pop();
                    },
                  ),
                Procesando(:final lento, :final sinConexion) =>
                    _Procesando(recibido: true, lento: lento, sinConexion: sinConexion),
                _ => const _Procesando(recibido: false),
              },
            ),
          ),
        );
      },
    );
  }
}

class _Procesando extends StatelessWidget {
  /// El servidor ya tiene el archivo; solo falta la calificación.
  final bool recibido;
  final bool lento;
  final bool sinConexion;
  const _Procesando({required this.recibido, this.lento = false, this.sinConexion = false});

  @override
  Widget build(BuildContext context) {
    final detalle = !recibido
        ? 'Enviando tu archivo. No cierres la aplicación.'
        : sinConexion
            ? 'Sin conexión, reintentando… Tu ensayo ya se recibió y se sigue calificando.'
            : lento
                ? 'Está tardando más de lo normal. Puedes salir de esta pantalla: tu calificación '
                    'aparecerá en "Mis entregas" cuando esté lista.'
                : 'Esto suele tardar unos segundos. Puedes salir de esta pantalla: tu calificación '
                    'aparecerá en "Mis entregas".';
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(color: AppTheme.guinda, strokeWidth: 6),
          ),
          const SizedBox(height: 28),
          Text(recibido ? 'Archivo recibido, procesando calificación...' : 'Enviando archivo...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.negro)),
          const SizedBox(height: 8),
          Text(detalle, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.grisInactivo)),
          if (recibido) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Salir y ver después'),
            ),
          ],
        ],
      ),
    );
  }
}
