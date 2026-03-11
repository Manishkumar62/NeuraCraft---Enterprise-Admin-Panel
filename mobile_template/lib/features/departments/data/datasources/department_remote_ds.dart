import '../../../../core/network/dio_client.dart';
import '../models/department_model.dart';

class DepartmentRemoteDataSource {
  final DioClient dioClient;

  DepartmentRemoteDataSource(this.dioClient);

  Future<List<DepartmentModel>> getDepartments() async {
    final res = await dioClient.dio.get('/departments/');
    return (res.data as List).map((e) => DepartmentModel.fromJson(e)).toList();
  }

  Future<DepartmentModel> getDepartmentById(int id) async {
    final response = await dioClient.dio.get('/departments/$id/');
    return DepartmentModel.fromJson(response.data);
  }

  Future<DepartmentModel> createDepartment(Map<String, dynamic> data) async {
    final response = await dioClient.dio.post('/departments/', data: data);
    return DepartmentModel.fromJson(response.data);
  }

  Future<DepartmentModel> updateDepartment(int id, Map<String, dynamic> data) async {
    final response = await dioClient.dio.put('/departments/$id/', data: data);

    return DepartmentModel.fromJson(response.data);
  }

  Future<void> deleteDepartment(int id) async {
    await dioClient.dio.delete('/departments/$id/');
  }
}
