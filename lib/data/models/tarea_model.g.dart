// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarea_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntregaResumenModel _$EntregaResumenModelFromJson(Map<String, dynamic> json) =>
    EntregaResumenModel(
      id: (json['id'] as num).toInt(),
      estado: json['estado'] as String,
      fechaEntrega: DateTime.parse(json['fechaEntrega'] as String),
    );

TareaModel _$TareaModelFromJson(Map<String, dynamic> json) => TareaModel(
  id: (json['id'] as num).toInt(),
  groupId: (json['groupId'] as num).toInt(),
  grupo: json['grupo'] as String,
  nombre: json['nombre'] as String,
  fechaApertura: DateTime.parse(json['fechaApertura'] as String),
  fechaCierre: DateTime.parse(json['fechaCierre'] as String),
  disponibilidad: json['disponibilidad'] as String,
  entrega: json['entrega'] == null
      ? null
      : EntregaResumenModel.fromJson(json['entrega'] as Map<String, dynamic>),
  pendiente: json['pendiente'] as bool? ?? false,
);
