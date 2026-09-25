import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/auth_tokens.dart';

part 'auth_response_model.g.dart';

@JsonSerializable(createToJson: false)
class AuthResponseModel extends AuthTokens {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.nombre,
    required super.correo,
    required super.rol,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}
