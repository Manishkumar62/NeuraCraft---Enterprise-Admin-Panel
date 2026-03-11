import '../entities/department_entity.dart';
import '../repositories/department_repository.dart';

class UpdateDepartment {
  final DepartmentRepository repository;

  UpdateDepartment(this.repository);

  Future<DepartmentEntity> call(int id, Map<String, dynamic> data) {
    return repository.updateDepartment(id, data);
  }
}