import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/tarea.dart';
import 'estado_entrega_badge.dart';

class TareaCard extends StatelessWidget {
  final Tarea tarea;
  final bool mostrarGrupo;
  final VoidCallback? onTap;

  const TareaCard({super.key, required this.tarea, this.mostrarGrupo = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cerrada = tarea.disponibilidad == Disponibilidad.cerrada;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: cerrada ? AppTheme.grisInactivo : AppTheme.guinda,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tarea.nombre,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    if (mostrarGrupo) ...[
                      const SizedBox(height: 2),
                      Text(tarea.grupo,
                          style: const TextStyle(fontSize: 13, color: AppTheme.grisInactivo)),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      Formatters.cierre(tarea.fechaCierre),
                      style: TextStyle(
                        fontSize: 13,
                        color: tarea.pendiente ? AppTheme.guinda : AppTheme.grisInactivo,
                        fontWeight: tarea.pendiente ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              EstadoEntregaBadge(estado: tarea.entrega?.estado),
            ],
          ),
        ),
      ),
    );
  }
}
