import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/tarea.dart';

/// Etiqueta de estado de entrega (sección 4.8.3). [estado] null = "Sin entregar".
class EstadoEntregaBadge extends StatelessWidget {
  final EstadoEntrega? estado;
  const EstadoEntregaBadge({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final (texto, color) = switch (estado) {
      null => ('Sin entregar', AppTheme.grisInactivo),
      EstadoEntrega.enRevision => ('En revisión', AppTheme.guinda),
      EstadoEntrega.calificado => ('Calificado', AppTheme.verdeExito),
      EstadoEntrega.posiblePlagio => ('Posible plagio', AppTheme.rojoDeficiente),
      EstadoEntrega.error => ('Error', AppTheme.rojoDeficiente),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
