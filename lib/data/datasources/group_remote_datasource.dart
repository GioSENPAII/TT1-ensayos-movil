import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/grupo_model.dart';
import '../models/tarea_model.dart';

class GroupRemoteDatasource {
  final ApiClient _client;
  GroupRemoteDatasource(this._client);

  Future<List<GrupoModel>> misGrupos() async {
    final data = await _client.get(ApiConstants.misGrupos) as List<dynamic>;
    return data.map((e) => GrupoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TareaModel>> tareasDeGrupo(int groupId) async {
    final data = await _client.get(ApiConstants.tareasDeGrupo(groupId)) as List<dynamic>;
    return data.map((e) => TareaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GrupoModel> unirse(String codigo) async {
    final data = await _client.post(ApiConstants.unirseGrupo, {'codigo': codigo});
    return GrupoModel.fromJson(data as Map<String, dynamic>);
  }
}
