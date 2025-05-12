import 'package:equatable/equatable.dart';
import 'package:wordpress_app/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class PasswordResetCodeSent extends AuthState {
  final String email;

  const PasswordResetCodeSent({required this.email});

  @override
  List<Object> get props => [email];
}

class PasswordResetCodeVerified extends AuthState {
  final String email;
  final String resetToken;

  const PasswordResetCodeVerified({
    required this.email,
    required this.resetToken,
  });

  @override
  List<Object> get props => [email, resetToken];
}

class PasswordResetSuccess extends AuthState {}

class RegistrationCodeSent extends AuthState {
  final String email;

  const RegistrationCodeSent({required this.email});

  @override
  List<Object> get props => [email];
}

class RegistrationVerified extends AuthState {
  final String email;

  const RegistrationVerified({required this.email});

  @override
  List<Object> get props => [email];
}
