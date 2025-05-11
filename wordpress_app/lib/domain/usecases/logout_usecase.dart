import 'package:dartz/dartz.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, void>> call() async {
    return await _repository.logout();
  }
}
