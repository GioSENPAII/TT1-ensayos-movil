import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<String> register({
    required String nombre,
    required String apellidos,
    required String correo,
  }) =>
      _remote.register(nombre: nombre, apellidos: apellidos, correo: correo);

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
  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: 'access_token', value: tokens.accessToken);
    await _storage.write(key: 'refresh_token', value: tokens.refreshToken);
    await _storage.write(key: 'nombre', value: tokens.nombre);
    await _storage.write(key: 'correo', value: tokens.correo);
    await _storage.write(key: 'rol', value: tokens.rol);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: 'access_token');

  @override
  Future<String?> getNombre() => _storage.read(key: 'nombre');
}
