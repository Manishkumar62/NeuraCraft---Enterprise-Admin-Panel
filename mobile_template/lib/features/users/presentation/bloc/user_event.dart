abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class LoadUserById extends UserEvent {
  final int id;
  LoadUserById(this.id);
}

class CreateUserEvent extends UserEvent {
  final Map<String, dynamic> data;
  CreateUserEvent(this.data);
}

class UpdateUserEvent extends UserEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateUserEvent(this.id, this.data);
}

class DeleteUserEvent extends UserEvent {
  final int id;
  DeleteUserEvent(this.id);
}

class LoadRoles extends UserEvent {}

class LoadDepartments extends UserEvent {}