import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/entities/tarea.dart';
import '../bloc/grading/grading_bloc.dart';
import '../bloc/grading/grading_event.dart';
import '../bloc/grading/grading_state.dart';
import '../widgets/criterio_card.dart';
import '../widgets/mensaje_vacio.dart';
import '../widgets/resumen_calificacion_card.dart';

/// Reporte de calificación por rúbrica (GradingReportScreen, CU-ALU-03). Siempre se consulta al
/// servidor: no se muestra ningún reporte guardado localmente (E3, RNF-01).
class GradingReportScreen extends StatelessWidget {
  final int entregaId;
  const GradingReportScreen({super.key, required this.entregaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GradingBloc>()..add(ReporteRequested(entregaId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Reporte de calificación')),
        body: BlocBuilder<GradingBloc, GradingState>(
          builder: (context, state) {
            final entrega = state.detalle;
            if (entrega == null && state.detalleStatus == CargaStatus.failure) {
              return Center(
                child: MensajeVacio(
                  icono: Icons.wifi_off_outlined,
                  titulo: 'No se pudo cargar el reporte',
                  detalle: state.errorMessage,
                  textoBoton: 'Reintentar',
                  onPressed: () => context.read<GradingBloc>().add(ReporteRequested(entregaId)),
                ),
              );
            }
            if (entrega == null) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.guinda));
            }
            return RefreshIndicator(
              color: AppTheme.guinda,
              onRefresh: () async {
                final bloc = context.read<GradingBloc>()..add(ReporteRequested(entregaId));
                await bloc.stream.firstWhere((s) => s.detalleStatus != CargaStatus.loading);
              },
              child: _Contenido(entrega: entrega),
            );
          },
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  final Entrega entrega;
  const _Contenido({required this.entrega});

  @override
  Widget build(BuildContext context) {
    final reporte = entrega.reporte;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(entrega.tarea,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.negro)),
        const SizedBox(height: 2),
        Text('${entrega.grupo} · ${entrega.nombreArchivo}',
            style: const TextStyle(color: AppTheme.grisInactivo)),
        const SizedBox(height: 16),
        if (reporte == null)
          switch (entrega.estado) {
            // E1: aún en procesamiento
            EstadoEntrega.enRevision => const MensajeVacio(
                icono: Icons.hourglass_top_rounded,
                titulo: 'Tu ensayo se está calificando',
                detalle: 'Consulta de nuevo en unos momentos (desliza hacia abajo para actualizar).',
              ),
            _ => MensajeVacio(
                icono: Icons.error_outline,
                titulo: 'Tu ensayo no pudo calificarse',
                detalle: entrega.mensaje ?? 'Intenta enviarlo de nuevo desde la tarea.',
              ),
          }
        else ...[
          ResumenCalificacionCard(reporte: reporte),
          if (reporte.observacion != null && reporte.observacion!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(reporte.observacion!, style: const TextStyle(color: AppTheme.grisInactivo)),
          ],
          if (reporte.faltaContextoIntro || reporte.abusoVinetas) ...[
            const SizedBox(height: 12),
            if (reporte.faltaContextoIntro)
              const _Bandera(texto: 'Falta de contextualización inicial en la introducción'),
            if (reporte.abusoVinetas)
              const _Bandera(texto: 'Uso excesivo de listas o viñetas en lugar de párrafos'),
          ],
          const SizedBox(height: 20),
          const Text('Desglose por criterio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.negro)),
          const SizedBox(height: 4),
          const Text('Toca un criterio para ver el detalle.',
              style: TextStyle(fontSize: 13, color: AppTheme.grisInactivo)),
          const SizedBox(height: 10),
          ...reporte.criterios.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CriterioCard(criterio: c),
              )),
        ],
      ],
    );
  }
}

/// Bandera diagnóstica predefinida del motor (no es retroalimentación personalizada).
class _Bandera extends StatelessWidget {
  final String texto;
  const _Bandera({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.flag_outlined, size: 18, color: AppTheme.amarilloParcial),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13, color: AppTheme.negro))),
        ],
      ),
    );
  }
}
