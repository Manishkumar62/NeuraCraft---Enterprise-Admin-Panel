import '../../domain/entities/module_entity.dart';
import '../../domain/repositories/module_repository.dart';
import '../datasources/module_remote_ds.dart';

class ModuleRepositoryImpl implements ModuleRepository {
  final ModuleRemoteDataSource remote;

  ModuleRepositoryImpl(this.remote);

  @override
  Future<List<ModuleEntity>> getModules() {
    return remote.getModules();
  }

  @override
  Future<ModuleEntity> getModuleById(int id) {
    return remote.getModuleById(id);
  }

  @override
  Future<void> createModule(Map<String, dynamic> data) {
    return remote.createModule(data);
  }

  @override
  Future<void> updateModule(int id, Map<String, dynamic> data) {
    return remote.updateModule(id, data);
  }

  @override
  Future<void> deleteModule(int id) {
    return remote.deleteModule(id);
  }
}