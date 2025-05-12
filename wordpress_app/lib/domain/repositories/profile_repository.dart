import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/domain/entities/user.dart';

abstract class ProfileRepository {
  /// Upload a profile image and update the user's avatar
  Future<Either<Failure, User>> updateProfileImage(File imageFile);
  
  /// Get the current user's profile
  Future<Either<Failure, User>> getUserProfile();
}
