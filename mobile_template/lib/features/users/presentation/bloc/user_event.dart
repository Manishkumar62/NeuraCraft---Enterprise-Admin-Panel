abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class FetchUserById extends UserEvent {
  final int id;
  FetchUserById(this.id);
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