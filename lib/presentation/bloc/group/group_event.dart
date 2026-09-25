import 'package:equatable/equatable.dart';

abstract class GroupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Carga los grupos del alumno con sus tareas visibles.
class GroupsRequested extends GroupEvent {}

class JoinGroupSubmitted extends GroupEvent {
  final String codigo;
  JoinGroupSubmitted(this.codigo);

  @override
  List<Object?> get props => [codigo];
}

/// Limpia el resultado de la última inscripción (al salir de la pantalla).
class JoinGroupReset extends GroupEvent {}
