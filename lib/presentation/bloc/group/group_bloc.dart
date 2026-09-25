import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/grupo_con_tareas.dart';
import '../../../domain/repositories/group_repository.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _repository;

  GroupBloc(this._repository) : super(const GroupState()) {
    on<GroupsRequested>(_onGroupsRequested);
    on<JoinGroupSubmitted>(_onJoin);
    on<JoinGroupReset>((_, emit) => emit(state.copyWith(joinStatus: JoinStatus.idle)));
  }

  Future<void> _onGroupsRequested(GroupsRequested event, Emitter<GroupState> emit) async {
    emit(state.copyWith(status: GroupsStatus.loading));
    try {
      final grupos = await _repository.misGrupos();
      final conTareas = await Future.wait(grupos.map((g) async =>
          GrupoConTareas(grupo: g, tareas: await _repository.tareasDeGrupo(g.id))));
      emit(state.copyWith(status: GroupsStatus.loaded, grupos: conTareas));
    } on SessionExpiredException {
      // El AuthBloc se encarga de regresar al login
    } catch (e) {
      emit(state.copyWith(status: GroupsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onJoin(JoinGroupSubmitted event, Emitter<GroupState> emit) async {
    emit(state.copyWith(joinStatus: JoinStatus.submitting));
    try {
      final grupo = await _repository.unirse(event.codigo);
      emit(state.copyWith(
        joinStatus: JoinStatus.success,
        joinMessage: 'Te uniste a ${grupo.nombre}',
      ));
      add(GroupsRequested());
    } on SessionExpiredException {
      emit(state.copyWith(joinStatus: JoinStatus.idle));
    } catch (e) {
      emit(state.copyWith(joinStatus: JoinStatus.failure, joinMessage: e.toString()));
    }
  }
}
