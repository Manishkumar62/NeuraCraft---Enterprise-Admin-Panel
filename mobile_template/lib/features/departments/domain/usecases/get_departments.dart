import '../entities/department_entity.dart';
import '../repositories/department_repository.dart';

class GetDepartmentsforDepart {
  final DepartmentRepository repository;

  GetDepartmentsforDepart(this.repository);

  Future<List<DepartmentEntity>> call() {
    return repository.getDepartmentsforDepart();
  }
}