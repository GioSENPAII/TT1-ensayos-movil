import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Estado vacío o de error con acción opcional.
class MensajeVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? detalle;
  final String? textoBoton;
  final VoidCallback? onPressed;

  const MensajeVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.textoBoton,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 56, color: AppTheme.grisInactivo),
          const SizedBox(height: 12),
          Text(titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          if (detalle != null) ...[
            const SizedBox(height: 6),
            Text(detalle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.grisInactivo)),
          ],
          if (textoBoton != null && onPressed != null) ...[
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onPressed, child: Text(textoBoton!)),
          ],
        ],
      ),
    );
  }
}
