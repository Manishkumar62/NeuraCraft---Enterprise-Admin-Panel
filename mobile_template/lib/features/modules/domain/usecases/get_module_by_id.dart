import '../repositories/module_repository.dart';

class GetModuleById {
  final ModuleRepository repo;

  GetModuleById(this.repo);

  Future call(int id) {
    return repo.getModuleById(id);
  }
}