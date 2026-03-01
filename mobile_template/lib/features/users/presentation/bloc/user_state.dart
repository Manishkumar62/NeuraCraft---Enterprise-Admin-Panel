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

class UserActionSuccess extends UserState {}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}