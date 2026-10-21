import 'dart:typed_data';

import '../entities/aviso_privacidad.dart';
import '../entities/foto_perfil.dart';

abstract class ProfileRepository {
  Future<AvisoPrivacidad> avisoPrivacidad();

  /// JPEG de la foto del usuario en sesión, o null si no tiene.
  Future<Uint8List?> miFoto();

  Future<void> subirFoto(FotoPerfil foto);

  Future<void> eliminarFoto();
}
