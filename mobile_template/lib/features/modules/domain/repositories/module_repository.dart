import '../entities/module_entity.dart';

abstract class ModuleRepository {
  Future<List<ModuleEntity>> getModules();

  Future<ModuleEntity> getModuleById(int id);

  Future<void> createModule(Map<String, dynamic> data);

  Future<void> updateModule(int id, Map<String, dynamic> data);

  Future<void> deleteModule(int id);
}