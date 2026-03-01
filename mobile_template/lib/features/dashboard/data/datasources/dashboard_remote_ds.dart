import '../../../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

class DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSource(this.dioClient);

  Future<DashboardModel> getDashboardStats() async {
    final response = await dioClient.dio.get('/dashboard/stats/');
    return DashboardModel.fromJson(response.data);
  }
}