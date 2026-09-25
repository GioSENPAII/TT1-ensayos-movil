// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entrega_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CriterioModel _$CriterioModelFromJson(Map<String, dynamic> json) =>
    CriterioModel(
      criterio: json['criterio'] as String,
      puntajeObtenido: (json['puntajeObtenido'] as num).toDouble(),
      puntajeMaximo: (json['puntajeMaximo'] as num).toDouble(),
      detalles: json['detalles'] as String?,
      modificadoPorDocente: json['modificadoPorDocente'] as bool? ?? false,
      puntajeIa: (json['puntajeIa'] as num?)?.toDouble(),
    );

BanderasModel _$BanderasModelFromJson(Map<String, dynamic> json) =>
    BanderasModel(
      faltaContextoIntro: json['faltaContextoIntro'] as bool? ?? false,
      abusoVinetas: json['abusoVinetas'] as bool? ?? false,
    );

ReporteModel _$ReporteModelFromJson(Map<String, dynamic> json) => ReporteModel(
  calificacionFinal: (json['calificacionFinal'] as num).toDouble(),
  calificacionMaxima: (json['calificacionMaxima'] as num).toDouble(),
  observacion: json['observacion'] as String?,
  fechaEvaluacion: DateTime.parse(json['fechaEvaluacion'] as String),
  modificadoPorDocente: json['modificadoPorDocente'] as bool? ?? false,
  posiblePlagio: json['posiblePlagio'] as bool? ?? false,
  banderas: json['banderas'] == null
      ? null
      : BanderasModel.fromJson(json['banderas'] as Map<String, dynamic>),
  criterios:
      (json['criterios'] as List<dynamic>?)
          ?.map((e) => CriterioModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

EntregaModel _$EntregaModelFromJson(Map<String, dynamic> json) => EntregaModel(
  id: (json['id'] as num).toInt(),
  nombreArchivo: json['nombreArchivo'] as String,
  tamanoBytes: (json['tamanoBytes'] as num?)?.toInt() ?? 0,
  fechaEntrega: DateTime.parse(json['fechaEntrega'] as String),
  tareaId: (json['tareaId'] as num).toInt(),
  tarea: json['tarea'] as String,
  grupoId: (json['grupoId'] as num).toInt(),
  grupo: json['grupo'] as String,
  estado: json['estado'] as String,
  calificacionFinal: (json['calificacionFinal'] as num?)?.toDouble(),
  modificadoPorDocente: json['modificadoPorDocente'] as bool? ?? false,
  mensaje: json['mensaje'] as String?,
  reporte: json['reporte'] == null
      ? null
      : ReporteModel.fromJson(json['reporte'] as Map<String, dynamic>),
);
