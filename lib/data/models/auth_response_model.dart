import '../../domain/entities/auth_tokens.dart';

class AuthResponseModel extends AuthTokens {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.nombre,
    required super.correo,
    required super.rol,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      rol: json['rol'] as String,
    );
  }
}
