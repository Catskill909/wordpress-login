import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/domain/entities/user.dart';
import 'package:wordpress_app/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, User>> call(LoginParams params) async {
    return await _repository.login(params.username, params.password);
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;

  const LoginParams({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}
