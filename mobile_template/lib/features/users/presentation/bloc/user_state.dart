import '../../domain/entities/user_entity.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserListLoaded extends UserState {
  final List<UserEntity> users;

  UserListLoaded(this.users);
}

class SingleUserLoaded extends UserState {
  final UserEntity user;

  SingleUserLoaded(this.user);
}

class RolesLoaded extends UserState {
  final List<Map<String, dynamic>> roles;

  RolesLoaded(this.roles);
}

class DepartmentsLoaded extends UserState {
  final List<Map<String, dynamic>> departments;

  DepartmentsLoaded(this.departments);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}