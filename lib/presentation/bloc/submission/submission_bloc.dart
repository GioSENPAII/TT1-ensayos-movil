import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/archivo_pdf.dart';
import '../../../domain/repositories/submission_repository.dart';
import 'submission_event.dart';
import 'submission_state.dart';

class SubmissionBloc extends Bloc<SubmissionEvent, SubmissionState> {
  final SubmissionRepository _repository;

  SubmissionBloc(this._repository) : super(SubmissionIdle()) {
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
    try {
      final entrega = await _repository.enviar(tareaId: event.tareaId, archivo: archivo);
      emit(EnvioTerminado(entrega));
    } on SessionExpiredException {
      emit(SubmissionIdle());
    } on NetworkException catch (e) {
      // CU-ALU-02 E3: reintentar sin consumir un intento oficial
      emit(EnvioFallido(archivo, e.message, esDeRed: true));
    } catch (e) {
      emit(EnvioFallido(archivo, e.toString()));
    }
  }
}
