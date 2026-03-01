import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final DioClient dioClient;

  UserRemoteDataSource(this.dioClient);

  Future<List<UserModel>> getUsers() async {
    final response = await dioClient.dio.get('/users/');
    return (response.data as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  Future<UserModel> getUserById(int id) async {
    final response = await dioClient.dio.get('/users/$id/');
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> createUser(Map<String, dynamic> data) async {
    final response =
        await dioClient.dio.post('/users/register/', data: data);

    return UserModel.fromJson(response.data['user']);
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    final response =
        await dioClient.dio.put('/users/$id/', data: data);

    return UserModel.fromJson(response.data);
  }

  Future<void> deleteUser(int id) async {
    await dioClient.dio.delete('/users/$id/');
  }
}