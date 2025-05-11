import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/domain/entities/user.dart';
import 'package:wordpress_app/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await _repository.register(
      params.username,
      params.email,
      params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String username;
  final String email;
  final String password;

  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [username, email, password];
}
