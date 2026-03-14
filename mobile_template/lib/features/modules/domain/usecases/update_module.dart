import '../repositories/module_repository.dart';

class UpdateModule {
  final ModuleRepository repo;

  UpdateModule(this.repo);

  Future call(int id, Map<String, dynamic> data) {
    return repo.updateModule(id, data);
  }
}