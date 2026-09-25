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
      'rol': 'ALUMNO',
    });
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
    });
    return AuthResponseModel.fromJson(data);
  }

  Future<AuthResponseModel> login({
    required String correo,
    required String password,
  }) async {
    final data = await _client.post(ApiConstants.login, {
      'correo': correo,
      'password': password,
    });
    return AuthResponseModel.fromJson(data);
  }
}
