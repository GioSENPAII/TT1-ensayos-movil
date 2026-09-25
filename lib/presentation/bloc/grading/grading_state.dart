import 'package:equatable/equatable.dart';

import '../../../domain/entities/entrega.dart';

enum CargaStatus { initial, loading, loaded, failure }

class GradingState extends Equatable {
  final CargaStatus historialStatus;
  final List<Entrega> historial;
  final CargaStatus detalleStatus;
  final Entrega? detalle;
  final String? errorMessage;

  const GradingState({
    this.historialStatus = CargaStatus.initial,
    this.historial = const [],
    this.detalleStatus = CargaStatus.initial,
    this.detalle,
    this.errorMessage,
  });

  /// La entrega calificada más reciente, para el acceso rápido de Inicio.
  Entrega? get ultimaCalificada {
    for (final e in historial) {
      if (e.calificada) return e;
    }
    return null;
  }

  GradingState copyWith({
    CargaStatus? historialStatus,
    List<Entrega>? historial,
    CargaStatus? detalleStatus,
    Entrega? detalle,
    String? errorMessage,
  }) {
    return GradingState(
      historialStatus: historialStatus ?? this.historialStatus,
      historial: historial ?? this.historial,
      detalleStatus: detalleStatus ?? this.detalleStatus,
      detalle: detalle ?? this.detalle,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [historialStatus, historial, detalleStatus, detalle?.id, detalle?.estado, detalle?.calificacionFinal, errorMessage];
}
