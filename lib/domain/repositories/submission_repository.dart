import '../entities/archivo_pdf.dart';
import '../entities/entrega.dart';

abstract class SubmissionRepository {
  /// Envía el ensayo y espera su calificación (CU-ALU-02).
  Future<Entrega> enviar({required int tareaId, required ArchivoPdf archivo});

  /// Historial del alumno, de la más reciente a la más antigua (CU-ALU-04).
  Future<List<Entrega>> historial();

  /// Entrega con su reporte de calificación (CU-ALU-03).
  Future<Entrega> detalle(int id);
}
