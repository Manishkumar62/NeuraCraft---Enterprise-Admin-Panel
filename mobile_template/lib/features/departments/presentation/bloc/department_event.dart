abstract class DepartmentEvent {}

class LoadDepartments extends DepartmentEvent {}

class LoadDepartmentById extends DepartmentEvent {
  final int id;
  LoadDepartmentById(this.id);
}

class CreateDepartmentEvent extends DepartmentEvent {
  final Map<String, dynamic> data;
  CreateDepartmentEvent(this.data);
}

class UpdateDepartmentEvent extends DepartmentEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateDepartmentEvent(this.id, this.data);
}

class DeleteDepartmentEvent extends DepartmentEvent {
  final int id;
  DeleteDepartmentEvent(this.id);
}