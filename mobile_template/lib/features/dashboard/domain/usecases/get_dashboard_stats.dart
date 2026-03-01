import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStats {
  final DashboardRepository repository;

  GetDashboardStats(this.repository);

  Future<DashboardEntity> call() {
    return repository.getDashboardStats();
  }
}