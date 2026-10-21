import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/foto_perfil.dart';
import '../../../domain/repositories/profile_repository.dart';

enum FotoStatus { cargando, lista, guardando, error }

class FotoPerfilState extends Equatable {
  final FotoStatus status;

  /// JPEG de la foto actual; null si el alumno no tiene foto.
  final Uint8List? bytes;

  /// Error de la última acción, para mostrarlo una vez en un SnackBar.
  final String? mensaje;

  const FotoPerfilState({this.status = FotoStatus.cargando, this.bytes, this.mensaje});

  @override
  List<Object?> get props => [status, bytes, mensaje];
}

/// Foto de perfil del alumno: se elige de la galería o de Archivos (nunca de la cámara).
class FotoPerfilCubit extends Cubit<FotoPerfilState> {
  final ProfileRepository _repository;
  FotoPerfilCubit(this._repository) : super(const FotoPerfilState());

  Future<void> cargar() async {
    try {
      emit(FotoPerfilState(status: FotoStatus.lista, bytes: await _repository.miFoto()));
    } on SessionExpiredException {
      // El AuthBloc regresa al login
    } catch (_) {
      // Sin foto no se bloquea el perfil: se muestran las iniciales
      emit(const FotoPerfilState(status: FotoStatus.lista));
    }
  }

  Future<void> subir(FotoPerfil foto) async {
    if (foto.bytes.length > FotoPerfil.maxBytes) {
      emit(FotoPerfilState(
          status: FotoStatus.lista, bytes: state.bytes, mensaje: 'La imagen no debe superar 5 MB'));
      return;
    }
    await _guardar(() => _repository.subirFoto(foto));
  }

  Future<void> eliminar() => _guardar(_repository.eliminarFoto);

  Future<void> _guardar(Future<void> Function() accion) async {
    final anterior = state.bytes;
    emit(FotoPerfilState(status: FotoStatus.guardando, bytes: anterior));
    try {
      await accion();
      emit(FotoPerfilState(status: FotoStatus.lista, bytes: await _repository.miFoto()));
    } on SessionExpiredException {
      // El AuthBloc regresa al login
    } catch (e) {
      emit(FotoPerfilState(status: FotoStatus.lista, bytes: anterior, mensaje: e.toString()));
    }
  }
}
