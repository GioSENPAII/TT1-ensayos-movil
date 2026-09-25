import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/usuario_sesion.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final SessionStorage _session;
  final ApiClient _client;

  AuthRepositoryImpl(this._remote, this._session, this._client);

  @override
  Future<String> register({
    required String nombre,
    required String apellidos,
    required String correo,
  }) =>
      _remote.register(nombre: nombre, apellidos: apellidos, correo: correo);

  @override
  Future<String> resendToken(String correo) => _remote.resendToken(correo);

  @override
  Future<AuthTokens> verifyToken({
    required String correo,
    required String token,
    required String password,
  }) =>
      _remote.verifyToken(correo: correo, token: token, password: password);

  @override
  Future<AuthTokens> login({
    required String correo,
    required String password,
  }) =>
      _remote.login(correo: correo, password: password);

  @override
  Future<String> forgotPassword(String correo) => _remote.forgotPassword(correo);

  @override
  Future<String> resetPassword({
    required String correo,
    required String codigo,
    required String password,
  }) =>
      _remote.resetPassword(correo: correo, codigo: codigo, password: password);

  @override
  Future<void> saveSession(AuthTokens tokens) => _session.save(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        nombre: tokens.nombre,
        correo: tokens.correo,
        rol: tokens.rol,
      );

  @override
  Future<UsuarioSesion?> currentSession() async {
    final refresh = await _session.refreshToken;
    final nombre = await _session.nombre;
    final correo = await _session.correo;
    final rol = await _session.rol;
    if (refresh == null || nombre == null || correo == null || rol == null) return null;
    return UsuarioSesion(nombre: nombre, correo: correo, rol: rol);
  }

  @override
  Future<void> logout() async {
    final refresh = await _session.refreshToken;
    if (refresh != null) {
      try {
        await _remote.logout(refresh);
      } on AppException {
        // CU-AUTH-05 E1: sin red se borra igual la sesión local; el token expira solo
      }
    }
    await _session.clear();
  }

  @override
  Stream<void> get onSessionExpired => _client.onSessionExpired;
}
