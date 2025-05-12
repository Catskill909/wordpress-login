import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:wordpress_app/core/network/dio_client.dart';
import 'package:wordpress_app/core/storage/secure_storage_service.dart';
import 'package:wordpress_app/data/datasources/auth_remote_data_source.dart';
import 'package:wordpress_app/data/datasources/profile_remote_data_source.dart';
import 'package:wordpress_app/data/repositories/auth_repository_impl.dart';
import 'package:wordpress_app/data/repositories/profile_repository_impl.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_bloc.dart';
import 'package:wordpress_app/domain/blocs/profile/profile_bloc.dart';
import 'package:wordpress_app/domain/repositories/auth_repository.dart';
import 'package:wordpress_app/domain/repositories/profile_repository.dart';
import 'package:wordpress_app/domain/usecases/get_user_profile_usecase.dart';
import 'package:wordpress_app/domain/usecases/login_usecase.dart';
import 'package:wordpress_app/domain/usecases/logout_usecase.dart';
import 'package:wordpress_app/domain/usecases/register_usecase.dart';
import 'package:wordpress_app/domain/usecases/update_profile_image_usecase.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Core
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<Dio>(
    () => Dio(),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      dio: sl<Dio>(),
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorageService: sl<SecureStorageService>(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(
      repository: sl<ProfileRepository>(),
    ),
  );

  sl.registerLazySingleton<UpdateProfileImageUseCase>(
    () => UpdateProfileImageUseCase(
      repository: sl<ProfileRepository>(),
    ),
  );

  // BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
    ),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserProfileUseCase: sl<GetUserProfileUseCase>(),
      updateProfileImageUseCase: sl<UpdateProfileImageUseCase>(),
      authBloc: sl<AuthBloc>(),
    ),
  );
}
