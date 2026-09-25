import 'grupo.dart';
import 'tarea.dart';

class GrupoConTareas {
  final Grupo grupo;
  final List<Tarea> tareas;

  const GrupoConTareas({required this.grupo, required this.tareas});

  int get pendientes => tareas.where((t) => t.pendiente).length;
}
