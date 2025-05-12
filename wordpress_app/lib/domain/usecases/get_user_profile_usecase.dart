import 'package:dartz/dartz.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/domain/entities/user.dart';
import 'package:wordpress_app/domain/repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository _repository;

  GetUserProfileUseCase({required ProfileRepository repository})
      : _repository = repository;

  Future<Either<Failure, User>> call() async {
    return await _repository.getUserProfile();
  }
}
