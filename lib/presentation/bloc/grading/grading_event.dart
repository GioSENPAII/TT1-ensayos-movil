import 'package:equatable/equatable.dart';

abstract class GradingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Carga el historial de entregas (CU-ALU-04).
class HistorialRequested extends GradingEvent {}

/// Carga el reporte de una entrega (CU-ALU-03).
class ReporteRequested extends GradingEvent {
  final int entregaId;
  ReporteRequested(this.entregaId);

  @override
  List<Object?> get props => [entregaId];
}
