import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class SignupRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;
  final String firstName;
  final String lastName;
  final String phone;

  const SignupRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  @override
  List<Object?> get props => [
        username,
        email,
        password,
        passwordConfirm,
        firstName,
        lastName,
        phone,
      ];
}

class LogoutRequested extends AuthEvent {}
