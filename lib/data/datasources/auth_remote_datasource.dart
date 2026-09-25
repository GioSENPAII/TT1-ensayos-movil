import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDatasource {
  final ApiClient _client;
  AuthRemoteDatasource(this._client);

  Future<String> register({
    required String nombre,
    required String apellidos,
    required String correo,
  }) async {
    final data = await _client.post(ApiConstants.register, {
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'rol': 'ALUMNO', // la app móvil es exclusiva del alumno
    }, false);
    return data['message'] as String;
  }

  Future<String> resendToken(String correo) async {
    final data = await _client.post(ApiConstants.resendToken, {'correo': correo}, false);
    return data['message'] as String;
  }

  Future<AuthResponseModel> verifyToken({
    required String correo,
    required String token,
    required String password,
  }) async {
    final data = await _client.post(ApiConstants.verifyToken, {
      'correo': correo,
      'token': token,
      'password': password,
    }, false);
    return AuthResponseModel.fromJson(data);
  }

  Future<AuthResponseModel> login({
    required String correo,
    required String password,
  }) async {
    final data = await _client.post(ApiConstants.login, {
      'correo': correo,
      'password': password,
    }, false);
    return AuthResponseModel.fromJson(data);
  }

  Future<String> forgotPassword(String correo) async {
    final data = await _client.post(ApiConstants.forgotPassword, {'correo': correo}, false);
    return data['message'] as String;
  }

  Future<String> resetPassword({
    required String correo,
    required String codigo,
    required String password,
  }) async {
    final data = await _client.post(ApiConstants.resetPassword, {
      'correo': correo,
      'codigo': codigo,
      'password': password,
    }, false);
    return data['message'] as String;
  }

  Future<void> logout(String refreshToken) =>
      _client.post(ApiConstants.logout, {'refreshToken': refreshToken}, false);
}
