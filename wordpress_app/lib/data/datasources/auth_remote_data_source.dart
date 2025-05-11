import 'package:wordpress_app/core/constants/app_constants.dart';
import 'package:wordpress_app/core/errors/exceptions.dart';
import 'package:wordpress_app/core/network/dio_client.dart';
import 'package:wordpress_app/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<UserModel> register(String username, String email, String password);
  Future<void> forgotPassword(String email);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dioClient.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      return {
        'token': response['token'],
        'user': UserModel.fromJson(response['user']),
      };
    } catch (e) {
      throw ApiException(message: 'Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(String username, String email, String password) async {
    try {
      final response = await _dioClient.post(
        AppConstants.registerEndpoint,
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      
      return UserModel.fromJson(response);
    } catch (e) {
      throw ApiException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.post(
        AppConstants.forgotPasswordEndpoint,
        data: {
          'email': email,
        },
      );
    } catch (e) {
      throw ApiException(message: 'Password reset request failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.get(AppConstants.userEndpoint);
      return UserModel.fromJson(response);
    } catch (e) {
      throw ApiException(message: 'Failed to get user data: ${e.toString()}');
    }
  }
}
