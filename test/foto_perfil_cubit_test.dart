import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:ensayos_movil/core/errors/app_exceptions.dart';
import 'package:ensayos_movil/domain/entities/aviso_privacidad.dart';
import 'package:ensayos_movil/domain/entities/foto_perfil.dart';
import 'package:ensayos_movil/domain/repositories/profile_repository.dart';
import 'package:ensayos_movil/presentation/bloc/profile/foto_perfil_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class RepoFalso implements ProfileRepository {
  Uint8List? foto;
  Object? errorAlSubir;
  int subidas = 0;

  @override
  Future<Uint8List?> miFoto() async => foto;

  @override
  Future<void> subirFoto(FotoPerfil f) async {
    subidas++;
    if (errorAlSubir != null) throw errorAlSubir!;
    foto = f.bytes;
  }

  @override
  Future<void> eliminarFoto() async => foto = null;

  @override
  Future<AvisoPrivacidad> avisoPrivacidad() => throw UnimplementedError();
}

void main() {
  final jpeg = Uint8List.fromList([1, 2, 3]);

  blocTest<FotoPerfilCubit, FotoPerfilState>(
    'sin foto carga lista y vacía',
    build: () => FotoPerfilCubit(RepoFalso()),
    act: (c) => c.cargar(),
    expect: () => [const FotoPerfilState(status: FotoStatus.lista)],
  );

  blocTest<FotoPerfilCubit, FotoPerfilState>(
    'subir muestra la nueva foto',
    build: () => FotoPerfilCubit(RepoFalso()),
    act: (c) => c.subir(FotoPerfil(nombre: 'yo.png', bytes: jpeg)),
    expect: () => [
      const FotoPerfilState(status: FotoStatus.guardando),
      FotoPerfilState(status: FotoStatus.lista, bytes: jpeg),
    ],
  );

  final grande = RepoFalso();
  blocTest<FotoPerfilCubit, FotoPerfilState>(
    'una imagen de más de 5 MB no se envía',
    build: () => FotoPerfilCubit(grande),
    act: (c) => c.subir(FotoPerfil(nombre: 'g.jpg', bytes: Uint8List(FotoPerfil.maxBytes + 1))),
    expect: () => [
      const FotoPerfilState(status: FotoStatus.lista, mensaje: 'La imagen no debe superar 5 MB'),
    ],
    verify: (_) => expect(grande.subidas, 0),
  );

  blocTest<FotoPerfilCubit, FotoPerfilState>(
    'si el servidor rechaza la imagen se conserva la anterior y se muestra el error',
    build: () => FotoPerfilCubit(RepoFalso()
      ..foto = jpeg
      ..errorAlSubir = const ClientException(400, 'La imagen debe ser JPG o PNG')),
    seed: () => FotoPerfilState(status: FotoStatus.lista, bytes: jpeg),
    act: (c) => c.subir(FotoPerfil(nombre: 'x.png', bytes: Uint8List(10))),
    expect: () => [
      FotoPerfilState(status: FotoStatus.guardando, bytes: jpeg),
      FotoPerfilState(status: FotoStatus.lista, bytes: jpeg, mensaje: 'La imagen debe ser JPG o PNG'),
    ],
  );

  blocTest<FotoPerfilCubit, FotoPerfilState>(
    'quitar la foto vuelve a las iniciales',
    build: () => FotoPerfilCubit(RepoFalso()..foto = jpeg),
    seed: () => FotoPerfilState(status: FotoStatus.lista, bytes: jpeg),
    act: (c) => c.eliminar(),
    expect: () => [
      FotoPerfilState(status: FotoStatus.guardando, bytes: jpeg),
      const FotoPerfilState(status: FotoStatus.lista),
    ],
  );
}
