import '../entities/role_entity.dart';
import '../repositories/role_repository.dart';

class UpdateRole {
  final RoleRepository repository;

  UpdateRole(this.repository);

  Future<RoleEntity> call(int id, Map<String, dynamic> data) {
    return repository.updateRole(id, data);
  }
}