import '../../domain/entities/grupo.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDatasource _remote;
  GroupRepositoryImpl(this._remote);

  @override
  Future<List<Grupo>> misGrupos() async =>
      (await _remote.misGrupos()).map((m) => m.toEntity()).toList();

  @override
  Future<List<Tarea>> tareasDeGrupo(int groupId) async =>
      (await _remote.tareasDeGrupo(groupId)).map((m) => m.toEntity()).toList();

  @override
  Future<Grupo> unirse(String codigo) async =>
      (await _remote.unirse(codigo.trim().toUpperCase())).toEntity();
}
