import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/entrega.dart';
import '../bloc/grading/grading_bloc.dart';
import '../bloc/grading/grading_event.dart';
import '../bloc/grading/grading_state.dart';
import '../navigation/navegacion.dart';
import '../widgets/estado_entrega_badge.dart';
import '../widgets/mensaje_vacio.dart';

/// Historial de entregas (SubmissionHistoryScreen, CU-ALU-04), de la más reciente a la más antigua.
class SubmissionHistoryScreen extends StatelessWidget {
  const SubmissionHistoryScreen({super.key});

  Future<void> _refrescar(BuildContext context) async {
    final bloc = context.read<GradingBloc>()..add(HistorialRequested());
    await bloc.stream.firstWhere((s) => s.historialStatus != CargaStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis entregas'), automaticallyImplyLeading: false),
      body: BlocBuilder<GradingBloc, GradingState>(
        builder: (context, state) {
          if (state.historial.isEmpty &&
              (state.historialStatus == CargaStatus.loading || state.historialStatus == CargaStatus.initial)) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.guinda));
          }
          if (state.historial.isEmpty && state.historialStatus == CargaStatus.failure) {
            return Center(
              child: MensajeVacio(
                icono: Icons.wifi_off_outlined,
                titulo: 'No se pudo cargar tu historial',
                detalle: state.errorMessage,
                textoBoton: 'Reintentar',
                onPressed: () => context.read<GradingBloc>().add(HistorialRequested()),
              ),
            );
          }
          return RefreshIndicator(
            color: AppTheme.guinda,
            onRefresh: () => _refrescar(context),
            child: state.historial.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 120),
                    MensajeVacio(
                      icono: Icons.assignment_outlined,
                      titulo: 'Aún no has enviado ningún ensayo',
                      detalle: 'Únete a un grupo y envía tu primer ensayo.', // CU-ALU-04 E1
                    ),
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.historial.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _EntregaCard(entrega: state.historial[i]),
                  ),
          );
        },
      ),
    );
  }
}

class _EntregaCard extends StatelessWidget {
  final Entrega entrega;
  const _EntregaCard({required this.entrega});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => abrirReporte(context, entrega.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.guinda),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entrega.tarea, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(entrega.nombreArchivo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppTheme.grisInactivo)),
                    Text('${entrega.grupo} · ${Formatters.fechaHora(entrega.fechaEntrega)}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.grisInactivo)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (entrega.calificacionFinal != null)
                    Text(Formatters.calificacion(entrega.calificacionFinal!),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.guinda,
                          fontFamily: AppTheme.fuenteMono,
                          letterSpacing: AppTheme.espaciadoCifras,
                        )),
                  const SizedBox(height: 4),
                  EstadoEntregaBadge(estado: entrega.estado),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
