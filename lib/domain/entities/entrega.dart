import 'reporte.dart';
import 'tarea.dart';

/// Entrega de un ensayo (CU-ALU-02/04). [reporte] solo viene en el detalle y si ya se calificó.
class Entrega {
  final int id;
  final String nombreArchivo;
  final int tamanoBytes;
  final DateTime fechaEntrega;
  final int tareaId;
  final String tarea;
  final int grupoId;
  final String grupo;
  final EstadoEntrega estado;
  final double? calificacionFinal;
  final bool modificadoPorDocente;

  /// Explicación cuando [estado] es error (p. ej. el motor de IA no respondió).
  final String? mensaje;
  final Reporte? reporte;

  const Entrega({
    required this.id,
    required this.nombreArchivo,
    required this.tamanoBytes,
    required this.fechaEntrega,
    required this.tareaId,
    required this.tarea,
    required this.grupoId,
    required this.grupo,
    required this.estado,
    required this.calificacionFinal,
    required this.modificadoPorDocente,
    required this.mensaje,
    required this.reporte,
  });

  bool get calificada =>
      estado == EstadoEntrega.calificado || estado == EstadoEntrega.posiblePlagio;
}
