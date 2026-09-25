import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/grupo.dart';

part 'grupo_model.g.dart';

@JsonSerializable(createToJson: false)
class GrupoModel {
  final int id;
  final String nombre;
  final String profesor;
  final String estado;
  final DateTime fechaInscripcion;

  const GrupoModel({
    required this.id,
    required this.nombre,
    required this.profesor,
    required this.estado,
    required this.fechaInscripcion,
  });

  factory GrupoModel.fromJson(Map<String, dynamic> json) => _$GrupoModelFromJson(json);

  Grupo toEntity() => Grupo(
        id: id,
        nombre: nombre,
        profesor: profesor,
        activo: estado == 'ACTIVO',
        fechaInscripcion: fechaInscripcion,
      );
}
