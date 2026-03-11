
import '../datasources/department_remote_ds.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/repositories/department_repository.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentRemoteDataSource remote;

  DepartmentRepositoryImpl(this.remote);

  @override
  Future<List<DepartmentEntity>> getDepartmentsforDepart() {
    return remote.getDepartments();
  }

  @override
  Future<DepartmentEntity> getDepartmentById(int id) {
    return remote.getDepartmentById(id);
  }

  @override
  Future<DepartmentEntity> createDepartment(Map<String, dynamic> data) {
    return remote.createDepartment(data);
  }

  @override
  Future<DepartmentEntity> updateDepartment(int id, Map<String, dynamic> data) {
    return remote.updateDepartment(id, data);
  }

  @override
  Future<void> deleteDepartment(int id) {
    return remote.deleteDepartment(id);
  }
}
