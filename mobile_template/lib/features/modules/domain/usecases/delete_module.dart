import '../repositories/module_repository.dart';

class DeleteModule {
  final ModuleRepository repo;

  DeleteModule(this.repo);

  Future call(int id) {
    return repo.deleteModule(id);
  }
}