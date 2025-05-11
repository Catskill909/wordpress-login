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
      // For JSON API User plugin, we need to use form data or URL parameters
      // The endpoint is in the format: /?json=json-api-user/register
      final response = await _dioClient.post(
        AppConstants.registerEndpoint,
        queryParameters: {
          'username': username,
          'email': email,
          'password': password,
          'nonce': '1234', // This is a placeholder, might need a real nonce
          'display_name': username, // Optional, using username as display name
        },
      );

      // Check if the registration was successful
      if (response['status'] == 'ok') {
        // Create a user model from the response
        // Since JSON API User doesn't return detailed user info on registration,
        // we'll create a basic user model with the provided information
        return UserModel(
          id: 0, // We don't know the ID yet
          username: username,
          email: email,
          firstName: '',
          lastName: '',
          roles: ['subscriber'], // Default role
        );
      } else if (response['error']) {
        // If there's an error message in the response
        throw ApiException(
            message: 'Registration failed: ${response['error']}');
      } else {
        throw ApiException(message: 'Registration failed: Unknown error');
      }
    } catch (e) {
      throw ApiException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      // For JSON API User plugin, we need to use query parameters
      final response = await _dioClient.post(
        AppConstants.forgotPasswordEndpoint,
        queryParameters: {
          'email': email,
          'nonce': '1234', // This is a placeholder, might need a real nonce
        },
      );

      // Check if the password reset request was successful
      if (response['status'] != 'ok') {
        if (response['error']) {
          throw ApiException(
              message: 'Password reset request failed: ${response['error']}');
        } else {
          throw ApiException(
              message: 'Password reset request failed: Unknown error');
        }
      }
    } catch (e) {
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
