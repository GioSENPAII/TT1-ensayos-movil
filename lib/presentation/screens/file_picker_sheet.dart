import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/archivo_pdf.dart';

/// Vista previa del PDF elegido y confirmación explícita antes de enviarlo
/// (FilePickerSheet, sección 4.6.4). Devuelve true si el alumno confirma.
class FilePickerSheet extends StatelessWidget {
  final ArchivoPdf archivo;
  final String tarea;
  const FilePickerSheet({super.key, required this.archivo, required this.tarea});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Confirmar envío',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.negro)),
            const SizedBox(height: 4),
            Text('Tarea: $tarea', style: const TextStyle(color: AppTheme.grisInactivo)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.grisClaro,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: AppTheme.rojoDeficiente, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(archivo.nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(Formatters.tamano(archivo.tamano),
                            style: const TextStyle(fontSize: 13, color: AppTheme.grisInactivo)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Una vez calificado, tu ensayo no podrá reemplazarse.',
              style: TextStyle(fontSize: 13, color: AppTheme.grisInactivo),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enviar ensayo', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
