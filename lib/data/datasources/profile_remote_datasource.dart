import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/aviso_privacidad.dart';
import '../../domain/entities/foto_perfil.dart';

class ProfileRemoteDatasource {
  final ApiClient _client;
  ProfileRemoteDatasource(this._client);

  Future<AvisoPrivacidad> avisoPrivacidad() async {
    final data = await _client.get(ApiConstants.avisoPrivacidad, auth: false) as Map<String, dynamic>;
    return AvisoPrivacidad(
      version: data['version'] as String,
      fechaActualizacion: data['fechaActualizacion'] as String,
      contenido: data['contenido'] as String,
    );
  }

  Future<Uint8List?> miFoto() => _client.getBytes(ApiConstants.miFoto);

  Future<void> subirFoto(FotoPerfil foto) => _client.postArchivo(
        ApiConstants.miFoto,
        metodo: 'PUT',
        campos: const {},
        campoArchivo: 'file',
        nombreArchivo: foto.nombre,
        bytes: foto.bytes,
        tipo: foto.nombre.toLowerCase().endsWith('.png')
            ? MediaType('image', 'png')
            : MediaType('image', 'jpeg'),
      );

  Future<void> eliminarFoto() => _client.delete(ApiConstants.miFoto);
}
