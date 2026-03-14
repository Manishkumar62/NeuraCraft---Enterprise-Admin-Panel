import '../entities/module_entity.dart';
import '../repositories/module_repository.dart';

class GetModules {
  final ModuleRepository repo;

  GetModules(this.repo);

  Future<List<ModuleEntity>> call() {
    return repo.getModules();
  }
}