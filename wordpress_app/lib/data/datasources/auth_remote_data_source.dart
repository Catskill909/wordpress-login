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

  AuthRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

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

      // Create a user model from the JWT response
      // The JWT response format is:
      // {
      //   "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
      //   "user_email": "your-email@example.com",
      //   "user_nicename": "admin",
      //   "user_display_name": "Admin"
      // }

      final userModel = UserModel(
        id: 1, // We don't have the ID in the response, using default admin ID
        username: response['user_nicename'] ?? '',
        email: response['user_email'] ?? '',
        firstName: response['user_display_name'] ?? '',
        lastName: '',
        roles: ['subscriber'], // Default role
      );

      return {
        'token': response['token'],
        'user': userModel,
      };
    } catch (e) {
      throw ApiException(message: 'Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(
      String username, String email, String password) async {
    try {
      print('Registration endpoint: ${AppConstants.registerEndpoint}');

      // Since we can't use the WordPress REST API for registration without admin privileges,
      // we'll inform the user to use the WordPress registration page
      throw ApiException(
          message:
              'Please register at ${AppConstants.registerEndpoint}\n\nUsername: $username\nEmail: $email');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      print(
          'Sending password reset request to: ${AppConstants.forgotPasswordEndpoint}');
      print('With parameters: user_login=$email');

      // For WordPress standard password reset, we'll redirect the user to the WordPress password reset page
      // This is a workaround since we can't directly call the password reset API
      // In a real app, you would implement a WebView to show this page to the user

      // For now, we'll just inform the user that they need to go to the WordPress password reset page
      throw ApiException(
          message:
              'Please go to ${AppConstants.forgotPasswordEndpoint} to reset your password');
    } catch (e) {
      print('Password reset exception: ${e.toString()}');
      throw ApiException(
          message: 'Password reset request failed: ${e.toString()}');
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
