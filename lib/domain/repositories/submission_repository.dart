import '../entities/archivo_pdf.dart';
import '../entities/entrega.dart';

abstract class SubmissionRepository {
  /// Envía el ensayo; el servidor responde de inmediato con la entrega EN_REVISION y la califica en
  /// segundo plano (RNF-09). El resultado se obtiene consultando [detalle] (CU-ALU-02).
  Future<Entrega> enviar({required int tareaId, required ArchivoPdf archivo});

  /// Historial del alumno, de la más reciente a la más antigua (CU-ALU-04).
  Future<List<Entrega>> historial();

  /// Entrega con su reporte de calificación (CU-ALU-03).
  Future<Entrega> detalle(int id);
}
