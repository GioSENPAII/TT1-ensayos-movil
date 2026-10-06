import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/reporte.dart';

/// Tarjeta resumen del reporte (sección 4.6.3): calificación final con indicador circular,
/// alerta de similitud histórica y leyenda "Revisado por docente".
class ResumenCalificacionCard extends StatelessWidget {
  final Reporte reporte;
  const ResumenCalificacionCard({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    final p = reporte.porcentaje;
    final color = p >= 0.8
        ? AppTheme.verdeExito
        : p >= 0.6
            ? AppTheme.amarilloParcial
            : AppTheme.rojoDeficiente;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (reporte.posiblePlagio)
            Container(
              width: double.infinity,
              color: AppTheme.rojoDeficiente,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Alerta de similitud histórica — Requiere revisión docente',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: p.clamp(0, 1).toDouble(),
                        strokeWidth: 9,
                        backgroundColor: AppTheme.grisClaro,
                        color: color,
                      ),
                      Center(
                        child: Text(
                          Formatters.calificacion(reporte.calificacionFinal),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.guinda,
                            fontFamily: AppTheme.fuenteMono,
                            letterSpacing: AppTheme.espaciadoCifras,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Calificación final',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.negro)),
                      Text('de ${Formatters.calificacion(reporte.calificacionMaxima)} puntos',
                          style: const TextStyle(color: AppTheme.grisInactivo)),
                      const SizedBox(height: 6),
                      Text('Evaluado el ${Formatters.fechaHora(reporte.fechaEvaluacion)}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.grisInactivo)),
                      if (reporte.modificadoPorDocente) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.guinda.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Revisado por docente',
                              style: TextStyle(fontSize: 12, color: AppTheme.guinda, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
