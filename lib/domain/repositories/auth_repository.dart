import '../entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<String> register({
    required String nombre,
    required String apellidos,
    required String correo,
  });

  Future<AuthTokens> verifyToken({
    required String correo,
    required String token,
    required String password,
  });

  Future<AuthTokens> login({
    required String correo,
    required String password,
  });

  Future<void> saveTokens(AuthTokens tokens);
  Future<void> clearTokens();
  Future<String?> getAccessToken();
  Future<String?> getNombre();
}
