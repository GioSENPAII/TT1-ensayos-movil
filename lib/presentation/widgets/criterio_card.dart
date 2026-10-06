import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/reporte.dart';

Color colorNivel(NivelCriterio nivel) => switch (nivel) {
      NivelCriterio.completo => AppTheme.verdeExito,
      NivelCriterio.parcial => AppTheme.amarilloParcial,
      NivelCriterio.nulo => AppTheme.rojoDeficiente,
    };

String etiquetaNivel(NivelCriterio nivel) => switch (nivel) {
      NivelCriterio.completo => 'Nivel Alto (100%)',
      NivelCriterio.parcial => 'Nivel Medio (50%)',
      NivelCriterio.nulo => 'Nivel Bajo (0%)',
    };

/// Tarjeta expandible de un criterio (secciones 4.6.3 y 4.8.3): barra lateral de 4 px con el color
/// del nivel, nombre y puntaje; al expandir, el nivel y su descripción de la Tabla 14.
class CriterioCard extends StatelessWidget {
  final CriterioReporte criterio;
  const CriterioCard({super.key, required this.criterio});

  @override
  Widget build(BuildContext context) {
    final color = colorNivel(criterio.nivel);
    const cifras = TextStyle(fontFamily: AppTheme.fuenteMono);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: color),
            Expanded(
              child: ExpansionTile(
                shape: const Border(),
                tilePadding: const EdgeInsets.only(left: 12, right: 8),
                title: Text(criterio.nombre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.negro)),
                subtitle: criterio.modificadoPorDocente
                    ? const Text('Revisado por docente',
                        style: TextStyle(fontSize: 12, color: AppTheme.guinda, fontWeight: FontWeight.w600))
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${Formatters.puntaje(criterio.obtenido)} / ${Formatters.puntaje(criterio.maximo)}',
                      style: cifras.copyWith(fontSize: 15, fontWeight: FontWeight.w700, color: color),
                    ),
                    const Icon(Icons.expand_more, color: AppTheme.grisInactivo),
                  ],
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 16, 14),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezados de nivel de la Tabla 14; la descripción viene del backend
                  Text(etiquetaNivel(criterio.nivel),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 4),
                  if (criterio.detalles != null && criterio.detalles!.isNotEmpty)
                    Text(criterio.detalles!, style: const TextStyle(color: AppTheme.negro, height: 1.35)),
                  const SizedBox(height: 8),
                  Text('Puntaje máximo: ${Formatters.puntaje(criterio.maximo)}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.grisInactivo)),
                  if (criterio.modificadoPorDocente && criterio.puntajeIa != null)
                    Text('Puntaje original del motor de IA: ${Formatters.puntaje(criterio.puntajeIa!)}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.grisInactivo)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
