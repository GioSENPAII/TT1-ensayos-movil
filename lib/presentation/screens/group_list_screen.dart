import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_event.dart';
import '../bloc/group/group_state.dart';
import '../navigation/navegacion.dart';
import '../widgets/mensaje_vacio.dart';
import '../widgets/tarea_card.dart';
import 'join_group_screen.dart';

/// Mis grupos (GroupListScreen, CU-ALU-01 pasos 1-2): cada grupo se expande para ver sus tareas.
class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis grupos')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.guinda,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.group_add_outlined),
        label: const Text('Unirse a un grupo'),
        onPressed: () {
          final bloc = context.read<GroupBloc>();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BlocProvider.value(value: bloc, child: const JoinGroupScreen()),
          ));
        },
      ),
      body: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          if (state.grupos.isEmpty && state.status == GroupsStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.guinda));
          }
          if (state.grupos.isEmpty) {
            return Center(
              child: MensajeVacio(
                icono: Icons.groups_outlined,
                titulo: 'Aún no perteneces a ningún grupo',
                detalle: 'Usa el botón "Unirse a un grupo" con el código que te dio tu profesor.',
              ),
            );
          }
          return RefreshIndicator(
            color: AppTheme.guinda,
            onRefresh: () async {
              final bloc = context.read<GroupBloc>()..add(GroupsRequested());
              await bloc.stream.firstWhere((s) => s.status != GroupsStatus.loading);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: state.grupos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final g = state.grupos[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    shape: const Border(),
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.grisClaro,
                      child: Icon(Icons.groups, color: AppTheme.guinda),
                    ),
                    title: Text(g.grupo.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${g.grupo.profesor}\nInscrito el ${Formatters.fecha(g.grupo.fechaInscripcion)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    children: g.tareas.isEmpty
                        ? const [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Este grupo aún no tiene tareas abiertas.',
                                  style: TextStyle(color: AppTheme.grisInactivo)),
                            )
                          ]
                        : g.tareas
                            .map((t) => Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TareaCard(
                                    tarea: t,
                                    mostrarGrupo: false,
                                    onTap: () => abrirTarea(context, t),
                                  ),
                                ))
                            .toList(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
