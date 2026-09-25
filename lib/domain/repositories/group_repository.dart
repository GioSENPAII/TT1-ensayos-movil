import '../entities/grupo.dart';
import '../entities/tarea.dart';

abstract class GroupRepository {
  Future<List<Grupo>> misGrupos();
  Future<List<Tarea>> tareasDeGrupo(int groupId);
  Future<Grupo> unirse(String codigo);
}
