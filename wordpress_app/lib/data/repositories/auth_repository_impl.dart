import 'package:dartz/dartz.dart';
import 'package:wordpress_app/core/constants/app_constants.dart';
import 'package:wordpress_app/core/errors/exceptions.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/core/storage/secure_storage_service.dart';
import 'package:wordpress_app/data/datasources/auth_remote_data_source.dart';
import 'package:wordpress_app/data/models/user_model.dart';
import 'package:wordpress_app/domain/entities/user.dart';
import 'package:wordpress_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorageService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorageService,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorageService = secureStorageService;

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final result = await _remoteDataSource.login(username, password);

      // Save token
      await _secureStorageService.saveString(
        AppConstants.tokenKey,
        result['token'],
      );

      // Save user data
      final user = result['user'] as UserModel;
      await _secureStorageService.saveObject(
        AppConstants.userKey,
        (result['user'] as UserModel).toJson(),
      );

      return Right(user);
    } on ApiException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(
      String username, String email, String password) async {
    try {
      final user = await _remoteDataSource.register(username, email, password);
      return Right(user);
    } on ApiException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordResetCode(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyPasswordResetCode(
      String email, String code) async {
    try {
      final resetToken = await _remoteDataSource.verifyResetCode(email, code);
      return Right(resetToken);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
      String email, String resetToken, String newPassword) async {
    try {
      await _remoteDataSource.resetPassword(email, resetToken, newPassword);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    // This is now just a wrapper around requestPasswordResetCode for backward compatibility
    return requestPasswordResetCode(email);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Always fetch from API first
      final user = await _remoteDataSource.getCurrentUser();
      await _secureStorageService.saveObject(AppConstants.userKey, user.toJson());
      return Right(user);
    } catch (e) {
      // Fallback to cache if API fails
      final userData = await _secureStorageService.getObject(AppConstants.userKey);
      if (userData != null) {
        return Right(UserModel.fromJson(userData));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _secureStorageService.delete(AppConstants.tokenKey);
      await _secureStorageService.delete(AppConstants.userKey);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token =
          await _secureStorageService.getString(AppConstants.tokenKey);
      return token != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> requestRegistrationCode(String email) async {
    try {
      await _remoteDataSource.requestRegistrationCode(email);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyRegistration(
      String email, String code) async {
    try {
      await _remoteDataSource.verifyRegistration(email, code);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
