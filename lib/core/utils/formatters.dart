import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _fecha = DateFormat("d 'de' MMMM 'de' y", 'es_MX');
  static final _fechaHora = DateFormat("d MMM y, HH:mm", 'es_MX');
  static final _hora = DateFormat('HH:mm', 'es_MX');

  static String fecha(DateTime d) => _fecha.format(d);

  /// Puntajes con un decimal cuando hace falta: 4 → "4", 0.25 → "0.25", 7.5 → "7.5".
  static String puntaje(double v) {
    final s = v.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String calificacion(double v) => v.toStringAsFixed(1);

  static String tamano(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  static String fechaHora(DateTime d) => _fechaHora.format(d);

  /// Texto relativo al cierre de una tarea: "Cierra hoy a las 18:00", "Cierra en 3 días".
  static String cierre(DateTime cierre, {DateTime? ahora}) {
    final now = ahora ?? DateTime.now();
    if (!cierre.isAfter(now)) return 'Cerró el ${fechaHora(cierre)}';
    final hoy = DateTime(now.year, now.month, now.day);
    final dia = DateTime(cierre.year, cierre.month, cierre.day);
    final dias = dia.difference(hoy).inDays;
    if (dias == 0) return 'Cierra hoy a las ${_hora.format(cierre)}';
    if (dias == 1) return 'Cierra mañana a las ${_hora.format(cierre)}';
    if (dias < 7) return 'Cierra en $dias días';
    return 'Cierra el ${fechaHora(cierre)}';
  }
}
