/// Datos del usuario con sesión iniciada.
class UsuarioSesion {
  final String nombre;
  final String correo;
  final String rol;

  const UsuarioSesion({required this.nombre, required this.correo, required this.rol});

  bool get esAlumno => rol == 'ALUMNO';
}
