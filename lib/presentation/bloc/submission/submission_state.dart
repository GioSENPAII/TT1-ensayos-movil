import 'package:equatable/equatable.dart';

import '../../../domain/entities/archivo_pdf.dart';
import '../../../domain/entities/entrega.dart';

/// Etapas de la carga (sección 4.6.1): selección → validación → envío/procesamiento → resultado.
abstract class SubmissionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmissionIdle extends SubmissionState {}

/// Archivo válido en cliente, esperando confirmación.
class ArchivoListo extends SubmissionState {
  final ArchivoPdf archivo;
  ArchivoListo(this.archivo);

  @override
  List<Object?> get props => [archivo.nombre, archivo.tamano];
}

/// Falló la validación en cliente (CU-ALU-02 E1/E2): no se contacta al servidor.
class ArchivoInvalido extends SubmissionState {
  final String mensaje;
  ArchivoInvalido(this.mensaje);

  @override
  List<Object?> get props => [mensaje, identityHashCode(this)];
}

class Enviando extends SubmissionState {
  final ArchivoPdf archivo;
  Enviando(this.archivo);

  @override
  List<Object?> get props => [archivo.nombre];
}

/// El servidor recibió el ensayo; [entrega.estado] dice si quedó calificado o con error del motor.
class EnvioTerminado extends SubmissionState {
  final Entrega entrega;
  EnvioTerminado(this.entrega);

  @override
  List<Object?> get props => [entrega.id, entrega.estado];
}

/// Error antes de registrar la entrega (red, tarea cerrada, PDF sin texto...). Puede reintentarse.
class EnvioFallido extends SubmissionState {
  final ArchivoPdf archivo;
  final String mensaje;
  final bool esDeRed;
  EnvioFallido(this.archivo, this.mensaje, {this.esDeRed = false});

  @override
  List<Object?> get props => [mensaje, identityHashCode(this)];
}
