import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../domain/entities/tarea.dart';
import '../bloc/grading/grading_bloc.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/submission/submission_bloc.dart';
import '../screens/assignment_detail_screen.dart';
import '../screens/grading_report_screen.dart';

/// Las pantallas empujadas desde el MainShell comparten sus blocs (grupos e historial) para
/// refrescarlos después de una entrega.
void abrirTarea(BuildContext context, Tarea tarea) {
  final groupBloc = context.read<GroupBloc>();
  final gradingBloc = context.read<GradingBloc>();
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: groupBloc),
        BlocProvider.value(value: gradingBloc),
        BlocProvider(create: (_) => sl<SubmissionBloc>()),
      ],
      child: AssignmentDetailScreen(tarea: tarea),
    ),
  ));
}

void abrirReporte(BuildContext context, int entregaId, {bool reemplazar = false}) {
  final route = MaterialPageRoute(builder: (_) => GradingReportScreen(entregaId: entregaId));
  if (reemplazar) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}
