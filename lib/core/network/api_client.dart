import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/app_exceptions.dart';
import '../storage/session_storage.dart';

/// Cliente HTTP único de la app (sección 4.6.5).
/// - Inyecta `Authorization: Bearer` en las peticiones autenticadas.
/// - Ante un 401 renueva la sesión con el refresh token y repite la petición una vez.
/// - Si la renovación falla, borra la sesión y avisa por [onSessionExpired].
class ApiClient {
  static const _timeout = Duration(seconds: 20); // RF-ALU-06

  final SessionStorage _session;
  final http.Client _http;
  final _sessionExpired = StreamController<void>.broadcast();
  Future<bool>? _refreshEnCurso;

  ApiClient(this._session, [http.Client? client]) : _http = client ?? http.Client();

  /// Emite cuando la sesión ya no puede renovarse; el AuthBloc manda al login.
  Stream<void> get onSessionExpired => _sessionExpired.stream;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, [Map<String, dynamic>? body, bool auth = true]) =>
      _send('POST', path, body: body, auth: auth);

  Future<dynamic> put(String path, Map<String, dynamic> body) =>
      _send('PUT', path, body: body);

  Future<dynamic> patch(String path, Map<String, dynamic> body) =>
      _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path,
      {Map<String, dynamic>? body, bool auth = true}) async {
    var response = await _request(method, path, body, auth);

    if (auth && response.statusCode == 401) {
      if (!await _renovarSesion()) {
        throw const SessionExpiredException();
      }
      response = await _request(method, path, body, auth);
      if (response.statusCode == 401) {
        await _expirarSesion();
        throw const SessionExpiredException();
      }
    }
    return _procesar(response);
  }

  Future<http.Response> _request(
      String method, String path, Map<String, dynamic>? body, bool auth) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await _session.accessToken;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final request = http.Request(method, Uri.parse('${ApiConstants.baseUrl}$path'))
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _http.send(request).timeout(_timeout);
      return await http.Response.fromStream(streamed).timeout(_timeout);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  dynamic _procesar(http.Response response) {
    final code = response.statusCode;
    final dynamic data = response.body.isEmpty ? null : _decode(response);

    if (code >= 200 && code < 300) return data;

    final mensaje = data is Map
        ? (data['detail'] ?? data['error'] ?? data['message'])?.toString()
        : null;
    if (code >= 500) {
      throw ServerException(mensaje ?? const ServerException().message);
    }
    throw ClientException(code, mensaje ?? 'Ocurrió un error. Intenta de nuevo.');
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }

  /// Una sola renovación a la vez: las peticiones concurrentes esperan el mismo resultado.
  Future<bool> _renovarSesion() {
    return _refreshEnCurso ??= _hacerRenovacion().whenComplete(() => _refreshEnCurso = null);
  }

  Future<bool> _hacerRenovacion() async {
    final refresh = await _session.refreshToken;
    if (refresh == null) {
      await _expirarSesion();
      return false;
    }
    try {
      final response = await _request(
          'POST', ApiConstants.refreshToken, {'refreshToken': refresh}, false);
      if (response.statusCode == 200) {
        final data = _decode(response) as Map<String, dynamic>;
        await _session.save(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        );
        return true;
      }
    } on NetworkException {
      rethrow; // sin red no se sabe si la sesión sigue viva: no se borra
    }
    await _expirarSesion();
    return false;
  }

  Future<void> _expirarSesion() async {
    await _session.clear();
    _sessionExpired.add(null);
  }
}
