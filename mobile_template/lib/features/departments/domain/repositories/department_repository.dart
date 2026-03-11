import '../../domain/entities/department_entity.dart';

abstract class DepartmentRepository {
  Future<List<DepartmentEntity>> getDepartmentsforDepart();

  Future<DepartmentEntity> getDepartmentById(int id);

  Future<DepartmentEntity> createDepartment(Map<String, dynamic> data);

  Future<DepartmentEntity> updateDepartment(int id, Map<String, dynamic> data);

  Future<void> deleteDepartment(int id);
}