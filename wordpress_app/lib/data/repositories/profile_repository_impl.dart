import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:wordpress_app/core/errors/exceptions.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/data/datasources/profile_remote_data_source.dart';
import 'package:wordpress_app/domain/entities/user.dart';
import 'package:wordpress_app/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, User>> updateProfileImage(File imageFile) async {
    try {
      // 1. Upload the image to WordPress media library
      final imageUrl = await _remoteDataSource.uploadProfileImage(imageFile);
      
      // 2. Get current user profile to get the user ID
      final currentUser = await _remoteDataSource.getUserProfile();
      
      // 3. Update the user's avatar URL
      final updatedUser = await _remoteDataSource.updateUserAvatar(
        currentUser.id,
        imageUrl,
      );
      
      return Right(updatedUser);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile() async {
    try {
      final user = await _remoteDataSource.getUserProfile();
      return Right(user);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
