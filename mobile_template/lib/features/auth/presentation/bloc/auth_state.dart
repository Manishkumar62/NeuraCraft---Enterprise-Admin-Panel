import 'package:equatable/equatable.dart';
import '../../../menu/domain/models/module_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;
  final List<AppModule> modules;

  const AuthAuthenticated({
    required this.user,
    required this.modules,
  });

  @override
  List<Object?> get props => [user, modules];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}