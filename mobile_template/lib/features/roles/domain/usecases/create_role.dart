import '../entities/role_entity.dart';
import '../repositories/role_repository.dart';

class CreateRole {
  final RoleRepository repository;

  CreateRole(this.repository);

  Future<RoleEntity> call(Map<String, dynamic> data) {
    return repository.createRole(data);
  }
}