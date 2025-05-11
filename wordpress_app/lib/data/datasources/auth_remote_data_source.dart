import 'package:dio/dio.dart';
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
      print(
          'Sending registration request to: ${AppConstants.registerEndpoint}');
      print('With parameters: username=$username, email=$email');

      // For WordPress REST API, we need to use JWT authentication
      // First, let's try to create a user using the WordPress REST API
      final response = await _dioClient.post(
        AppConstants.registerEndpoint,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'name': username, // Display name
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Log the full response for debugging
      print('Registration response: $response');

      // WordPress REST API returns the user object directly
      if (response != null && response['id'] != null) {
        print('User created with ID: ${response['id']}');
        return UserModel(
          id: response['id'],
          username: response['username'] ?? username,
          email: response['email'] ?? email,
          firstName: response['first_name'] ?? '',
          lastName: response['last_name'] ?? '',
          roles: response['roles'] ?? ['subscriber'],
        );
      } else {
        print('Unknown registration error - no user data in response');
        throw ApiException(
            message: 'Registration failed: No user data returned');
      }
    } catch (e) {
      print('Registration exception: ${e.toString()}');

      // Try to extract error message from DioException
      if (e is DioException && e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData['message'] != null) {
          throw ApiException(
              message: 'Registration failed: ${errorData['message']}');
        }
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
