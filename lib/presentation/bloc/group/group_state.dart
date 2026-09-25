import 'package:equatable/equatable.dart';

import '../../../domain/entities/grupo_con_tareas.dart';
import '../../../domain/entities/tarea.dart';

enum GroupsStatus { initial, loading, loaded, failure }

enum JoinStatus { idle, submitting, success, failure }

class GroupState extends Equatable {
  final GroupsStatus status;
  final List<GrupoConTareas> grupos;
  final String? errorMessage;

  final JoinStatus joinStatus;
  final String? joinMessage;

  const GroupState({
    this.status = GroupsStatus.initial,
    this.grupos = const [],
    this.errorMessage,
    this.joinStatus = JoinStatus.idle,
    this.joinMessage,
  });

  /// Tareas abiertas sin entrega de todos los grupos, las que cierran primero arriba.
  List<Tarea> get tareasPendientes {
    final todas = grupos.expand((g) => g.tareas).where((t) => t.pendiente).toList()
      ..sort((a, b) => a.fechaCierre.compareTo(b.fechaCierre));
    return todas;
  }

  GroupState copyWith({
    GroupsStatus? status,
    List<GrupoConTareas>? grupos,
    String? errorMessage,
    JoinStatus? joinStatus,
    String? joinMessage,
  }) {
    return GroupState(
      status: status ?? this.status,
      grupos: grupos ?? this.grupos,
      errorMessage: errorMessage,
      joinStatus: joinStatus ?? this.joinStatus,
      joinMessage: joinMessage,
    );
  }

  @override
  List<Object?> get props => [status, grupos, errorMessage, joinStatus, joinMessage];
}
