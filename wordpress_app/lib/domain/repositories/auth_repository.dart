import 'package:dartz/dartz.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> register(String username, String email, String password);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
}
