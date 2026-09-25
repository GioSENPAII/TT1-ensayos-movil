import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _fecha = DateFormat("d 'de' MMMM 'de' y", 'es_MX');
  static final _fechaHora = DateFormat("d MMM y, HH:mm", 'es_MX');
  static final _hora = DateFormat('HH:mm', 'es_MX');

  static String fecha(DateTime d) => _fecha.format(d);
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
