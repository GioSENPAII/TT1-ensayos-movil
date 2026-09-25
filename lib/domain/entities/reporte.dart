/// Nivel de cumplimiento de un criterio: define su color (sección 4.8.1).
enum NivelCriterio { completo, parcial, nulo }

class CriterioReporte {
  final String nombre;
  final double obtenido;
  final double maximo;
  final String? detalles;
  final bool modificadoPorDocente;
  final double? puntajeIa;

  const CriterioReporte({
    required this.nombre,
    required this.obtenido,
    required this.maximo,
    required this.detalles,
    required this.modificadoPorDocente,
    required this.puntajeIa,
  });

  NivelCriterio get nivel {
    if (obtenido >= maximo) return NivelCriterio.completo;
    if (obtenido <= 0) return NivelCriterio.nulo;
    return NivelCriterio.parcial;
  }
}

/// Reporte de calificación por rúbrica (CU-ALU-03).
class Reporte {
  final double calificacionFinal;
  final double calificacionMaxima;
  final String? observacion;
  final DateTime fechaEvaluacion;
  final bool modificadoPorDocente;
  final bool posiblePlagio;
  final bool faltaContextoIntro;
  final bool abusoVinetas;
  final List<CriterioReporte> criterios;

  const Reporte({
    required this.calificacionFinal,
    required this.calificacionMaxima,
    required this.observacion,
    required this.fechaEvaluacion,
    required this.modificadoPorDocente,
    required this.posiblePlagio,
    required this.faltaContextoIntro,
    required this.abusoVinetas,
    required this.criterios,
  });

  double get porcentaje => calificacionMaxima == 0 ? 0 : calificacionFinal / calificacionMaxima;
}
