import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_event.dart';
import '../bloc/group/group_state.dart';
import '../widgets/mensaje_vacio.dart';
import '../widgets/tarea_card.dart';
import 'group_list_screen.dart';
import 'join_group_screen.dart';

/// Inicio (HomeScreen, Tabla 58): tareas pendientes y resumen de grupos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _abrirUnirse(BuildContext context) {
    final bloc = context.read<GroupBloc>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(value: bloc, child: const JoinGroupScreen()),
    ));
  }

  void _abrirGrupos(BuildContext context) {
    final bloc = context.read<GroupBloc>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(value: bloc, child: const GroupListScreen()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final nombre = auth is AuthAuthenticated ? auth.nombre : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Unirse a un grupo',
            icon: const Icon(Icons.group_add_outlined),
            onPressed: () => _abrirUnirse(context),
          ),
        ],
      ),
      body: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          if (state.grupos.isEmpty &&
              (state.status == GroupsStatus.loading || state.status == GroupsStatus.initial)) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.guinda));
          }
          if (state.status == GroupsStatus.failure && state.grupos.isEmpty) {
            return Center(
              child: MensajeVacio(
                icono: Icons.wifi_off_outlined,
                titulo: 'No se pudo cargar tu información',
                detalle: state.errorMessage,
                textoBoton: 'Reintentar',
                onPressed: () => context.read<GroupBloc>().add(GroupsRequested()),
              ),
            );
          }

          final pendientes = state.tareasPendientes;
          return RefreshIndicator(
            color: AppTheme.guinda,
            onRefresh: () async {
              final bloc = context.read<GroupBloc>()..add(GroupsRequested());
              await bloc.stream.firstWhere((s) => s.status != GroupsStatus.loading);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Hola, $nombre',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.negro)),
                const SizedBox(height: 4),
                const Text('Este es el resumen de tus grupos y tareas.',
                    style: TextStyle(color: AppTheme.grisInactivo)),
                const SizedBox(height: 24),
                if (state.grupos.isEmpty)
                  MensajeVacio(
                    icono: Icons.groups_outlined,
                    titulo: 'Aún no perteneces a ningún grupo',
                    detalle: 'Pide a tu profesor el código de acceso de 6 caracteres para unirte.',
                    textoBoton: 'Unirse a un grupo',
                    onPressed: () => _abrirUnirse(context),
                  )
                else ...[
                  _Seccion(titulo: 'Tareas pendientes', contador: pendientes.length),
                  const SizedBox(height: 8),
                  if (pendientes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No tienes tareas pendientes por ahora.',
                          style: TextStyle(color: AppTheme.grisInactivo)),
                    )
                  else
                    ...pendientes.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TareaCard(tarea: t),
                        )),
                  const SizedBox(height: 24),
                  _Seccion(
                    titulo: 'Mis grupos',
                    contador: state.grupos.length,
                    accion: TextButton(
                      onPressed: () => _abrirGrupos(context),
                      child: const Text('Ver todos', style: TextStyle(color: AppTheme.guinda)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...state.grupos.take(3).map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppTheme.grisClaro,
                              child: Icon(Icons.groups, color: AppTheme.guinda),
                            ),
                            title: Text(g.grupo.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(g.grupo.profesor),
                            trailing: g.pendientes > 0
                                ? Badge(
                                    label: Text('${g.pendientes}'),
                                    backgroundColor: AppTheme.guinda,
                                  )
                                : null,
                            onTap: () => _abrirGrupos(context),
                          ),
                        ),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final int contador;
  final Widget? accion;
  const _Seccion({required this.titulo, required this.contador, this.accion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.negro)),
        const SizedBox(width: 8),
        Text('($contador)', style: const TextStyle(color: AppTheme.grisInactivo)),
        const Spacer(),
        ?accion,
      ],
    );
  }
}
