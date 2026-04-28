class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String nombre;
  final String correo;
  final String rol;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.nombre,
    required this.correo,
    required this.rol,
  });
}
