import '../../domain/entities/module_entity.dart';

abstract class ModuleState {}

class ModuleInitial extends ModuleState {}

class ModuleLoading extends ModuleState {}

class ModuleLoaded extends ModuleState {
  final List<ModuleEntity> modules;

  ModuleLoaded(this.modules);
}

class SingleModuleLoaded extends ModuleState {
  final ModuleEntity module;

  SingleModuleLoaded(this.module);
}

class ModuleSaved extends ModuleState {}

class ModuleError extends ModuleState {
  final String message;

  ModuleError(this.message);
}