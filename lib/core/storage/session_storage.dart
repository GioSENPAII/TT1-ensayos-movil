import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tokens y datos del alumno en Keychain (iOS) / almacenamiento cifrado (Android), RNF-03.
class SessionStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kNombre = 'nombre';
  static const _kCorreo = 'correo';
  static const _kRol = 'rol';

  final FlutterSecureStorage _storage;
  SessionStorage(this._storage);

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    String? nombre,
    String? correo,
    String? rol,
  }) async {
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
    if (nombre != null) await _storage.write(key: _kNombre, value: nombre);
    if (correo != null) await _storage.write(key: _kCorreo, value: correo);
    if (rol != null) await _storage.write(key: _kRol, value: rol);
  }

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);
  Future<String?> get nombre => _storage.read(key: _kNombre);
  Future<String?> get correo => _storage.read(key: _kCorreo);
  Future<String?> get rol => _storage.read(key: _kRol);

  Future<void> clear() => _storage.deleteAll();
}
