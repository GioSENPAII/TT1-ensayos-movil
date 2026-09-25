import '../entities/auth_tokens.dart';
import '../entities/usuario_sesion.dart';

abstract class AuthRepository {
  Future<String> register({
    required String nombre,
    required String apellidos,
    required String correo,
  });

  Future<String> resendToken(String correo);

  Future<AuthTokens> verifyToken({
    required String correo,
    required String token,
    required String password,
  });

  Future<AuthTokens> login({
    required String correo,
    required String password,
  });

  Future<String> forgotPassword(String correo);

  Future<String> resetPassword({
    required String correo,
    required String codigo,
    required String password,
  });

  Future<void> saveSession(AuthTokens tokens);

  /// Sesión guardada en el dispositivo, o null si no hay.
  Future<UsuarioSesion?> currentSession();

  /// Invalida la sesión en el servidor (si hay red) y la borra del dispositivo (CU-AUTH-05).
  Future<void> logout();

  /// Emite cuando la sesión expira y no pudo renovarse.
  Stream<void> get onSessionExpired;
}
