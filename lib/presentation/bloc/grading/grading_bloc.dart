import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/entities/tarea.dart';
import '../../../domain/repositories/submission_repository.dart';
import 'grading_event.dart';
import 'grading_state.dart';

class GradingBloc extends Bloc<GradingEvent, GradingState> {
  final SubmissionRepository _repository;

  /// Mientras haya entregas EN_REVISION se vuelven a consultar solas (calificación asíncrona, C6).
  final Duration intervaloConsulta;
  Timer? _timerDetalle;
  Timer? _timerHistorial;

  GradingBloc(this._repository, {this.intervaloConsulta = const Duration(seconds: 3)})
      : super(const GradingState()) {
    on<HistorialRequested>(_onHistorial);
    on<ReporteRequested>(_onReporte);
  }

  Future<void> _onHistorial(HistorialRequested event, Emitter<GradingState> emit) async {
    // Las actualizaciones automáticas no muestran el indicador de carga
    if (state.historial.isEmpty) emit(state.copyWith(historialStatus: CargaStatus.loading));
    try {
      final historial = await _repository.historial();
      emit(state.copyWith(historialStatus: CargaStatus.loaded, historial: historial));
      _timerHistorial?.cancel();
      if (historial.any((e) => e.estado == EstadoEntrega.enRevision)) {
        _timerHistorial = Timer(intervaloConsulta, () {
          if (!isClosed) add(HistorialRequested());
        });
      }
    } on SessionExpiredException {
      // El AuthBloc regresa al login
    } catch (e) {
      emit(state.copyWith(historialStatus: CargaStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onReporte(ReporteRequested event, Emitter<GradingState> emit) async {
    if (state.detalle?.id != event.entregaId) {
      emit(state.copyWith(detalleStatus: CargaStatus.loading));
    }
    try {
      final entrega = await _repository.detalle(event.entregaId);
      emit(state.copyWith(detalleStatus: CargaStatus.loaded, detalle: entrega));
      _timerDetalle?.cancel();
      if (entrega.estado == EstadoEntrega.enRevision) {
        _timerDetalle = Timer(intervaloConsulta, () {
          if (!isClosed) add(ReporteRequested(event.entregaId));
        });
      }
    } on SessionExpiredException {
      // El AuthBloc regresa al login
    } catch (e) {
      emit(state.copyWith(detalleStatus: CargaStatus.failure, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _timerDetalle?.cancel();
    _timerHistorial?.cancel();
    return super.close();
  }
}
