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

/// Procesamiento del envío (UploadProgressScreen, CU-ALU-02 pasos 6-7). Mientras se envía no se
/// permite regresar, para evitar envíos duplicados (sección 4.6.4).
class UploadProgressScreen extends StatelessWidget {
  final int tareaId;
  const UploadProgressScreen({super.key, required this.tareaId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubmissionBloc, SubmissionState>(
      listener: (context, state) {
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
                _ => const _Procesando(),
              },
            ),
          ),
        );
      },
    );
  }
}

class _Procesando extends StatelessWidget {
  const _Procesando();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(color: AppTheme.guinda, strokeWidth: 6),
          ),
          SizedBox(height: 28),
          Text('Archivo recibido, procesando calificación...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.negro)),
          SizedBox(height: 8),
          Text('Esto puede tardar unos segundos. No cierres la aplicación.',
              textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grisInactivo)),
        ],
      ),
    );
  }
}
