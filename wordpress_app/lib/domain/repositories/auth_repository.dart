import 'package:dartz/dartz.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> register(
      String username, String email, String password);

  // Password reset flow
  Future<Either<Failure, void>> requestPasswordResetCode(String email);
  Future<Either<Failure, String>> verifyPasswordResetCode(
      String email, String code);
  Future<Either<Failure, void>> resetPassword(
      String email, String resetToken, String newPassword);

  // Legacy method (will be updated to use the new flow)
  Future<Either<Failure, void>> forgotPassword(String email);

  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
}
