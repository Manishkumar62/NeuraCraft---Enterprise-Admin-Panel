import '../entities/department_entity.dart';
import '../repositories/department_repository.dart';

class CreateDepartment {
  final DepartmentRepository repository;

  CreateDepartment(this.repository);

  Future<DepartmentEntity> call(Map<String, dynamic> data) {
    return repository.createDepartment(data);
  }
}