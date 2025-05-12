import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginEvent({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;

  const RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [username, email, password];
}

class RequestPasswordResetCodeEvent extends AuthEvent {
  final String email;

  const RequestPasswordResetCodeEvent({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

class VerifyPasswordResetCodeEvent extends AuthEvent {
  final String email;
  final String code;

  const VerifyPasswordResetCodeEvent({
    required this.email,
    required this.code,
  });

  @override
  List<Object> get props => [email, code];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String resetToken;
  final String newPassword;

  const ResetPasswordEvent({
    required this.email,
    required this.resetToken,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, resetToken, newPassword];
}

// Legacy event (kept for backward compatibility)
class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

class LogoutEvent extends AuthEvent {}
