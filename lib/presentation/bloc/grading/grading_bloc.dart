import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../domain/repositories/submission_repository.dart';
import 'grading_event.dart';
import 'grading_state.dart';

class GradingBloc extends Bloc<GradingEvent, GradingState> {
  final SubmissionRepository _repository;

  GradingBloc(this._repository) : super(const GradingState()) {
    on<HistorialRequested>(_onHistorial);
    on<ReporteRequested>(_onReporte);
  }

  Future<void> _onHistorial(HistorialRequested event, Emitter<GradingState> emit) async {
    emit(state.copyWith(historialStatus: CargaStatus.loading));
    try {
      final historial = await _repository.historial();
      emit(state.copyWith(historialStatus: CargaStatus.loaded, historial: historial));
    } on SessionExpiredException {
      // El AuthBloc regresa al login
    } catch (e) {
      emit(state.copyWith(historialStatus: CargaStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onReporte(ReporteRequested event, Emitter<GradingState> emit) async {
    emit(state.copyWith(detalleStatus: CargaStatus.loading));
    try {
      final entrega = await _repository.detalle(event.entregaId);
      emit(state.copyWith(detalleStatus: CargaStatus.loaded, detalle: entrega));
    } on SessionExpiredException {
      // El AuthBloc regresa al login
    } catch (e) {
      emit(state.copyWith(detalleStatus: CargaStatus.failure, errorMessage: e.toString()));
    }
  }
}
