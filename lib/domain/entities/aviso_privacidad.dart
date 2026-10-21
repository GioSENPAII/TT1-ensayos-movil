/// Aviso de privacidad integral que el alumno acepta al registrarse (texto en Markdown).
class AvisoPrivacidad {
  final String version;
  final String fechaActualizacion;
  final String contenido;

  const AvisoPrivacidad({
    required this.version,
    required this.fechaActualizacion,
    required this.contenido,
  });
}
