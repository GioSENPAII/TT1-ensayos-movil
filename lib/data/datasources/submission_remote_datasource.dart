import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/archivo_pdf.dart';
import '../models/entrega_model.dart';

class SubmissionRemoteDatasource {
  final ApiClient _client;
  SubmissionRemoteDatasource(this._client);

  Future<EntregaModel> enviar({required int tareaId, required ArchivoPdf archivo}) async {
    final data = await _client.postArchivo(
      ApiConstants.entregas,
      campos: {'assignmentId': '$tareaId'},
      campoArchivo: 'file',
      nombreArchivo: archivo.nombre,
      bytes: archivo.bytes, // 20 s como cualquier petición (RF-ALU-06): el servidor responde 202 al recibir
    );
    return EntregaModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<EntregaModel>> historial() async {
    final data = await _client.get(ApiConstants.misEntregas) as List<dynamic>;
    return data.map((e) => EntregaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EntregaModel> detalle(int id) async {
    final data = await _client.get(ApiConstants.entrega(id));
    return EntregaModel.fromJson(data as Map<String, dynamic>);
  }
}
