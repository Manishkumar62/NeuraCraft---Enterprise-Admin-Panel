import '../../../../core/network/dio_client.dart';
import '../models/module_model.dart';

class ModuleRemoteDataSource {
  final DioClient dioClient;

  ModuleRemoteDataSource(this.dioClient);

  Future<List<ModuleModel>> getModules() async {
    final res = await dioClient.dio.get('/modules/');
    return (res.data as List)
        .map((e) => ModuleModel.fromJson(e))
        .toList();
  }

  Future<ModuleModel> getModuleById(int id) async {
    final res = await dioClient.dio.get('/modules/$id/with-permissions/');
    return ModuleModel.fromJson(res.data);
  }

  Future<void> createModule(Map<String, dynamic> data) async {
    await dioClient.dio.post('/modules/create-with-permissions/', data: data);
  }

  Future<void> updateModule(int id, Map<String, dynamic> data) async {
    await dioClient.dio.put('/modules/$id/update-with-permissions/', data: data);
  }

  Future<void> deleteModule(int id) async {
    await dioClient.dio.delete('/modules/$id/');
  }
}
