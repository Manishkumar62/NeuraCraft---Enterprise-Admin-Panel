import '../repositories/module_repository.dart';

class CreateModule {
  final ModuleRepository repo;

  CreateModule(this.repo);

  Future call(Map<String, dynamic> data) {
    return repo.createModule(data);
  }
}