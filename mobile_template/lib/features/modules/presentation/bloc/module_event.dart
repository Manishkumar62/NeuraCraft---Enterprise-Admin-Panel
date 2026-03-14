abstract class ModuleEvent {}

class LoadModules extends ModuleEvent {}

class LoadModuleById extends ModuleEvent {
  final int id;

  LoadModuleById(this.id);
}

class CreateModuleEvent extends ModuleEvent {
  final Map<String, dynamic> data;

  CreateModuleEvent(this.data);
}

class UpdateModuleEvent extends ModuleEvent {
  final int id;
  final Map<String, dynamic> data;

  UpdateModuleEvent(this.id, this.data);
}

class DeleteModuleEvent extends ModuleEvent {
  final int id;

  DeleteModuleEvent(this.id);
}