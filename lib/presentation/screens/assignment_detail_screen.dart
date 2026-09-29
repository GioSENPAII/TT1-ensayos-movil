import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/tarea.dart';
import '../bloc/grading/grading_bloc.dart';
import '../bloc/grading/grading_event.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_event.dart';
import '../bloc/group/group_state.dart';
import '../bloc/submission/submission_bloc.dart';
import '../bloc/submission/submission_event.dart';
import '../bloc/submission/submission_state.dart';
import '../navigation/navegacion.dart';
import '../widgets/estado_entrega_badge.dart';
import 'file_picker_sheet.dart';
import 'upload_progress_screen.dart';

/// Detalle de la tarea con el botón de carga (AssignmentDetailScreen, CU-ALU-02 pasos 1-3).
class AssignmentDetailScreen extends StatelessWidget {
  final Tarea tarea;
  const AssignmentDetailScreen({super.key, required this.tarea});

  /// La versión más reciente de la tarea (cambia después de entregar).
  Tarea _actual(GroupState state) {
    for (final g in state.grupos) {
      for (final t in g.tareas) {
        if (t.id == tarea.id) return t;
      }
    }
    return tarea;
  }

  Future<void> _elegirArchivo(BuildContext context) async {
    final bloc = context.read<SubmissionBloc>();
    // El selector nativo solo muestra archivos .pdf (CU-ALU-02)
    final archivo = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['pdf']);
    if (archivo == null) return;
    bloc.add(ArchivoSeleccionado(
      nombre: archivo.name,
      tamano: await archivo.length() ?? 0,
      leer: archivo.readAsBytes,
    ));
  }

  Future<void> _confirmar(BuildContext context, ArchivoListo listo, Tarea t) async {
    final submissionBloc = context.read<SubmissionBloc>();
    final confirmado = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => FilePickerSheet(archivo: listo.archivo, tarea: t.nombre),
    );
    if (!context.mounted) return;
    if (confirmado != true) {
      submissionBloc.add(ArchivoDescartado());
      return;
    }
    final groupBloc = context.read<GroupBloc>();
    final gradingBloc = context.read<GradingBloc>();
    submissionBloc.add(EnvioConfirmado(t.id));
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: submissionBloc),
          BlocProvider.value(value: groupBloc),
          BlocProvider.value(value: gradingBloc),
        ],
        child: UploadProgressScreen(tareaId: t.id),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubmissionBloc, SubmissionState>(
      listener: (context, state) {
        if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
        if (state is EnvioTerminado) {
          // El alumno salió de la pantalla de progreso y la calificación llegó mientras veía la tarea
          context.read<GroupBloc>().add(GroupsRequested());
          context.read<GradingBloc>().add(HistorialRequested());
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.entrega.calificada
                ? 'Tu ensayo ya fue calificado'
                : 'Tu ensayo no pudo calificarse; puedes enviarlo de nuevo'),
          ));
          context.read<SubmissionBloc>().add(ArchivoDescartado());
        } else if (state is ArchivoInvalido) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensaje), backgroundColor: AppTheme.rojoDeficiente),
          );
        } else if (state is ArchivoListo) {
          _confirmar(context, state, _actual(context.read<GroupBloc>().state));
        }
      },
      child: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, groupState) {
          final t = _actual(groupState);
          final entrega = t.entrega;
          final abierta = t.disponibilidad == Disponibilidad.abierta;
          // Se puede entregar si la tarea está abierta y no hay entrega, o si la anterior falló
          final puedeEntregar = abierta && (entrega == null || entrega.estado == EstadoEntrega.error);
          final calificada = entrega != null &&
              (entrega.estado == EstadoEntrega.calificado || entrega.estado == EstadoEntrega.posiblePlagio);

          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de la tarea')),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(t.nombre,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.negro)),
                const SizedBox(height: 4),
                Text(t.grupo, style: const TextStyle(fontSize: 15, color: AppTheme.grisInactivo)),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _Fila(icono: Icons.lock_open_outlined, etiqueta: 'Apertura',
                            valor: Formatters.fechaHora(t.fechaApertura)),
                        const Divider(height: 24),
                        _Fila(icono: Icons.event_outlined, etiqueta: 'Cierre',
                            valor: Formatters.fechaHora(t.fechaCierre)),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.flag_outlined, color: AppTheme.guinda, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                                child: Text('Estado', style: TextStyle(color: AppTheme.grisInactivo))),
                            EstadoEntregaBadge(estado: entrega?.estado),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  abierta ? Formatters.cierre(t.fechaCierre) : 'El plazo de entrega ya cerró.',
                  style: TextStyle(
                    color: abierta ? AppTheme.guinda : AppTheme.grisInactivo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                if (calificada)
                  ElevatedButton.icon(
                    onPressed: () => abrirReporte(context, entrega.id),
                    icon: const Icon(Icons.assessment_outlined),
                    label: const Text('Ver reporte de calificación', style: TextStyle(fontSize: 16)),
                  )
                else if (entrega?.estado == EstadoEntrega.enRevision)
                  const _Aviso(
                    icono: Icons.hourglass_top_rounded,
                    texto: 'Tu ensayo se está calificando. Consulta el resultado en unos momentos.',
                  ),
                if (puedeEntregar) ...[
                  if (entrega?.estado == EstadoEntrega.error)
                    const _Aviso(
                      icono: Icons.error_outline,
                      texto: 'Tu envío anterior no pudo calificarse. Puedes enviarlo de nuevo.',
                      color: AppTheme.rojoDeficiente,
                    ),
                  const SizedBox(height: 12),
                  BlocBuilder<SubmissionBloc, SubmissionState>(
                    builder: (context, s) => ElevatedButton.icon(
                      onPressed: s is Enviando || s is Procesando ? null : () => _elegirArchivo(context),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Subir archivo', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Solo archivos PDF de hasta 10 MB con texto seleccionable.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.grisInactivo)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _Fila({required this.icono, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: AppTheme.guinda, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(etiqueta, style: const TextStyle(color: AppTheme.grisInactivo))),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  const _Aviso({required this.icono, required this.texto, this.color = AppTheme.guinda});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
