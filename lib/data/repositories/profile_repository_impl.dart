import 'dart:typed_data';

import '../../domain/entities/aviso_privacidad.dart';
import '../../domain/entities/foto_perfil.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _remote;
  ProfileRepositoryImpl(this._remote);

  @override
  Future<AvisoPrivacidad> avisoPrivacidad() => _remote.avisoPrivacidad();

  @override
  Future<Uint8List?> miFoto() => _remote.miFoto();

  @override
  Future<void> subirFoto(FotoPerfil foto) => _remote.subirFoto(foto);

  @override
  Future<void> eliminarFoto() => _remote.eliminarFoto();
}
