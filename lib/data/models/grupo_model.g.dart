// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grupo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrupoModel _$GrupoModelFromJson(Map<String, dynamic> json) => GrupoModel(
  id: (json['id'] as num).toInt(),
  nombre: json['nombre'] as String,
  profesor: json['profesor'] as String,
  estado: json['estado'] as String,
  fechaInscripcion: DateTime.parse(json['fechaInscripcion'] as String),
);
