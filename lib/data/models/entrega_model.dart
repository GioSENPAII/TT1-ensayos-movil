import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/entrega.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/entities/tarea.dart';

part 'entrega_model.g.dart';

@JsonSerializable(createToJson: false)
class CriterioModel {
  final String criterio;
  final double puntajeObtenido;
  final double puntajeMaximo;
  final String? detalles;
  @JsonKey(defaultValue: false)
  final bool modificadoPorDocente;
  final double? puntajeIa;

  const CriterioModel({
    required this.criterio,
    required this.puntajeObtenido,
    required this.puntajeMaximo,
    required this.detalles,
    required this.modificadoPorDocente,
    required this.puntajeIa,
  });

  factory CriterioModel.fromJson(Map<String, dynamic> json) => _$CriterioModelFromJson(json);

  CriterioReporte toEntity() => CriterioReporte(
        nombre: criterio,
        obtenido: puntajeObtenido,
        maximo: puntajeMaximo,
        detalles: detalles,
        modificadoPorDocente: modificadoPorDocente,
        puntajeIa: puntajeIa,
      );
}

@JsonSerializable(createToJson: false)
class BanderasModel {
  @JsonKey(defaultValue: false)
  final bool faltaContextoIntro;
  @JsonKey(defaultValue: false)
  final bool abusoVinetas;

  const BanderasModel({required this.faltaContextoIntro, required this.abusoVinetas});

  factory BanderasModel.fromJson(Map<String, dynamic> json) => _$BanderasModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ReporteModel {
  final double calificacionFinal;
  final double calificacionMaxima;
  final String? observacion;
  final DateTime fechaEvaluacion;
  @JsonKey(defaultValue: false)
  final bool modificadoPorDocente;
  @JsonKey(defaultValue: false)
  final bool posiblePlagio;
  final BanderasModel? banderas;
  @JsonKey(defaultValue: <CriterioModel>[])
  final List<CriterioModel> criterios;

  const ReporteModel({
    required this.calificacionFinal,
    required this.calificacionMaxima,
    required this.observacion,
    required this.fechaEvaluacion,
    required this.modificadoPorDocente,
    required this.posiblePlagio,
    required this.banderas,
    required this.criterios,
  });

  factory ReporteModel.fromJson(Map<String, dynamic> json) => _$ReporteModelFromJson(json);

  Reporte toEntity() => Reporte(
        calificacionFinal: calificacionFinal,
        calificacionMaxima: calificacionMaxima,
        observacion: observacion,
        fechaEvaluacion: fechaEvaluacion,
        modificadoPorDocente: modificadoPorDocente,
        posiblePlagio: posiblePlagio,
        faltaContextoIntro: banderas?.faltaContextoIntro ?? false,
        abusoVinetas: banderas?.abusoVinetas ?? false,
        criterios: criterios.map((c) => c.toEntity()).toList(),
      );
}

@JsonSerializable(createToJson: false)
class EntregaModel {
  final int id;
  final String nombreArchivo;
  @JsonKey(defaultValue: 0)
  final int tamanoBytes;
  final DateTime fechaEntrega;
  final int tareaId;
  final String tarea;
  final int grupoId;
  final String grupo;
  final String estado;
  final double? calificacionFinal;
  @JsonKey(defaultValue: false)
  final bool modificadoPorDocente;
  final String? mensaje;
  final ReporteModel? reporte;

  const EntregaModel({
    required this.id,
    required this.nombreArchivo,
    required this.tamanoBytes,
    required this.fechaEntrega,
    required this.tareaId,
    required this.tarea,
    required this.grupoId,
    required this.grupo,
    required this.estado,
    required this.calificacionFinal,
    required this.modificadoPorDocente,
    required this.mensaje,
    required this.reporte,
  });

  factory EntregaModel.fromJson(Map<String, dynamic> json) => _$EntregaModelFromJson(json);

  Entrega toEntity() => Entrega(
        id: id,
        nombreArchivo: nombreArchivo,
        tamanoBytes: tamanoBytes,
        fechaEntrega: fechaEntrega,
        tareaId: tareaId,
        tarea: tarea,
        grupoId: grupoId,
        grupo: grupo,
        estado: switch (estado) {
          'EN_REVISION' => EstadoEntrega.enRevision,
          'CALIFICADO' => EstadoEntrega.calificado,
          'POSIBLE_PLAGIO' => EstadoEntrega.posiblePlagio,
          _ => EstadoEntrega.error,
        },
        calificacionFinal: calificacionFinal,
        modificadoPorDocente: modificadoPorDocente,
        mensaje: mensaje,
        reporte: reporte?.toEntity(),
      );
}
