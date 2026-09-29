import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/archivo_pdf.dart';
import '../../../domain/entities/entrega.dart';
import '../../../domain/entities/tarea.dart';
import '../../../domain/repositories/submission_repository.dart';
import 'submission_event.dart';
import 'submission_state.dart';

class SubmissionBloc extends Bloc<SubmissionEvent, SubmissionState> {
  final SubmissionRepository _repository;

  /// Cada cuánto se consulta el estado de la entrega mientras se califica.
  final Duration intervaloConsulta;

  /// A partir de cuándo se avisa que está tardando más de lo normal.
  final Duration avisoLento;

  SubmissionBloc(
    this._repository, {
    this.intervaloConsulta = const Duration(seconds: 3),
    this.avisoLento = const Duration(seconds: 20),
  }) : super(SubmissionIdle()) {
    on<ArchivoSeleccionado>(_onSeleccionado);
    on<ArchivoDescartado>((_, emit) => emit(SubmissionIdle()));
    on<EnvioConfirmado>(_onEnviar);
  }

  Future<void> _onSeleccionado(ArchivoSeleccionado event, Emitter<SubmissionState> emit) async {
    // Validación en cliente antes de contactar al servidor (CU-ALU-02 paso 4, RF-ALU-05)
    if (!event.nombre.toLowerCase().endsWith('.pdf')) {
      emit(ArchivoInvalido('Solo se permiten archivos PDF'));
      return;
    }
    if (event.tamano > ArchivoPdf.maxBytes) {
      emit(ArchivoInvalido('El archivo supera el límite de 10 MB'));
      return;
    }
    if (event.tamano == 0) {
      emit(ArchivoInvalido('El archivo está vacío'));
      return;
    }
    try {
      emit(ArchivoListo(ArchivoPdf(nombre: event.nombre, bytes: await event.leer())));
    } catch (_) {
      emit(ArchivoInvalido('No se pudo leer el archivo seleccionado'));
    }
  }

  Future<void> _onEnviar(EnvioConfirmado event, Emitter<SubmissionState> emit) async {
    final actual = state;
    final archivo = switch (actual) {
      ArchivoListo(:final archivo) => archivo,
      EnvioFallido(:final archivo) => archivo,
      _ => null,
    };
    if (archivo == null) return;

    emit(Enviando(archivo));
    Entrega entrega;
    try {
      entrega = await _repository.enviar(tareaId: event.tareaId, archivo: archivo);
    } on SessionExpiredException {
      emit(SubmissionIdle());
      return;
    } on NetworkException catch (e) {
      // CU-ALU-02 E3: reintentar sin consumir un intento oficial
      emit(EnvioFallido(archivo, e.message, esDeRed: true));
      return;
    } catch (e) {
      emit(EnvioFallido(archivo, e.toString()));
      return;
    }
    await _esperarCalificacion(entrega, emit);
  }

  /// Consulta la entrega hasta que deje de estar EN_REVISION (corrección C6). Si el alumno sale de
  /// la pantalla el bloc se cierra y la consulta se detiene; la calificación sigue en el servidor.
  Future<void> _esperarCalificacion(Entrega entrega, Emitter<SubmissionState> emit) async {
    final inicio = DateTime.now();
    var actual = entrega;
    var sinConexion = false;
    while (actual.estado == EstadoEntrega.enRevision) {
      emit(Procesando(actual,
          lento: DateTime.now().difference(inicio) >= avisoLento, sinConexion: sinConexion));
      await Future<void>.delayed(intervaloConsulta);
      if (isClosed || emit.isDone) return;
      try {
        actual = await _repository.detalle(actual.id);
        sinConexion = false;
      } on SessionExpiredException {
        return;
      } on AppException {
        sinConexion = true; // se reintenta en la siguiente vuelta
      }
    }
    emit(EnvioTerminado(actual));
  }
}
