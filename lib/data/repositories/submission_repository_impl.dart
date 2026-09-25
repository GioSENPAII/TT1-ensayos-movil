import '../../domain/entities/archivo_pdf.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/repositories/submission_repository.dart';
import '../datasources/submission_remote_datasource.dart';

class SubmissionRepositoryImpl implements SubmissionRepository {
  final SubmissionRemoteDatasource _remote;
  SubmissionRepositoryImpl(this._remote);

  @override
  Future<Entrega> enviar({required int tareaId, required ArchivoPdf archivo}) async =>
      (await _remote.enviar(tareaId: tareaId, archivo: archivo)).toEntity();

  @override
  Future<List<Entrega>> historial() async =>
      (await _remote.historial()).map((m) => m.toEntity()).toList();

  @override
  Future<Entrega> detalle(int id) async => (await _remote.detalle(id)).toEntity();
}
