/// Grupo al que está inscrito el alumno (CU-ALU-01).
class Grupo {
  final int id;
  final String nombre;
  final String profesor;
  final bool activo;
  final DateTime fechaInscripcion;

  const Grupo({
    required this.id,
    required this.nombre,
    required this.profesor,
    required this.activo,
    required this.fechaInscripcion,
  });
}
