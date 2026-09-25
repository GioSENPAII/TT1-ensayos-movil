import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class SubmissionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// El alumno eligió un archivo en el selector nativo. Los bytes se leen solo si pasa la validación.
class ArchivoSeleccionado extends SubmissionEvent {
  final String nombre;
  final int tamano;
  final Future<Uint8List> Function() leer;
  ArchivoSeleccionado({required this.nombre, required this.tamano, required this.leer});

  @override
  List<Object?> get props => [nombre, tamano];
}

class ArchivoDescartado extends SubmissionEvent {}

/// Confirmó el envío del archivo elegido.
class EnvioConfirmado extends SubmissionEvent {
  final int tareaId;
  EnvioConfirmado(this.tareaId);

  @override
  List<Object?> get props => [tareaId];
}
