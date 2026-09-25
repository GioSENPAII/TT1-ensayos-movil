enum Disponibilidad { proxima, abierta, cerrada }

enum EstadoEntrega { enRevision, calificado, posiblePlagio, error }

/// Entrega del alumno en una tarea; null en [Tarea.entrega] significa "Sin entregar".
class EntregaResumen {
  final int id;
  final EstadoEntrega estado;
  final DateTime fechaEntrega;

  const EntregaResumen({
    required this.id,
    required this.estado,
    required this.fechaEntrega,
  });
}

/// Tarea de entrega visible para el alumno (ya abierta o cerrada).
class Tarea {
  final int id;
  final int groupId;
  final String grupo;
  final String nombre;
  final DateTime fechaApertura;
  final DateTime fechaCierre;
  final Disponibilidad disponibilidad;
  final EntregaResumen? entrega;

  /// Abierta y todavía sin entrega.
  final bool pendiente;

  const Tarea({
    required this.id,
    required this.groupId,
    required this.grupo,
    required this.nombre,
    required this.fechaApertura,
    required this.fechaCierre,
    required this.disponibilidad,
    required this.entrega,
    required this.pendiente,
  });
}
