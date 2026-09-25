import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/tarea.dart';

part 'tarea_model.g.dart';

@JsonSerializable(createToJson: false)
class EntregaResumenModel {
  final int id;
  final String estado;
  final DateTime fechaEntrega;

  const EntregaResumenModel({
    required this.id,
    required this.estado,
    required this.fechaEntrega,
  });

  factory EntregaResumenModel.fromJson(Map<String, dynamic> json) =>
      _$EntregaResumenModelFromJson(json);

  EntregaResumen toEntity() => EntregaResumen(
        id: id,
        estado: switch (estado) {
          'EN_REVISION' => EstadoEntrega.enRevision,
          'CALIFICADO' => EstadoEntrega.calificado,
          'POSIBLE_PLAGIO' => EstadoEntrega.posiblePlagio,
          _ => EstadoEntrega.error,
        },
        fechaEntrega: fechaEntrega,
      );
}

@JsonSerializable(createToJson: false)
class TareaModel {
  final int id;
  final int groupId;
  final String grupo;
  final String nombre;
  final DateTime fechaApertura;
  final DateTime fechaCierre;
  final String disponibilidad;
  final EntregaResumenModel? entrega;
  @JsonKey(defaultValue: false)
  final bool pendiente;

  const TareaModel({
    required this.id,
    required this.groupId,
    required this.grupo,
    required this.nombre,
    required this.fechaApertura,
    required this.fechaCierre,
    required this.disponibilidad,
    required this.entrega,
    required this.pendiente,
  });

  factory TareaModel.fromJson(Map<String, dynamic> json) => _$TareaModelFromJson(json);

  Tarea toEntity() => Tarea(
        id: id,
        groupId: groupId,
        grupo: grupo,
        nombre: nombre,
        fechaApertura: fechaApertura,
        fechaCierre: fechaCierre,
        disponibilidad: switch (disponibilidad) {
          'PROXIMA' => Disponibilidad.proxima,
          'ABIERTA' => Disponibilidad.abierta,
          _ => Disponibilidad.cerrada,
        },
        entrega: entrega?.toEntity(),
        pendiente: pendiente,
      );
}
