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
      // First, get a nonce for registration
      print('Getting nonce for registration');
      final nonceResponse = await _dioClient.get(
        '${AppConstants.baseUrl}/api/get_nonce/',
        queryParameters: {
          'controller': 'user',
          'method': 'register',
        },
      );

      final nonce = nonceResponse['nonce'];
      print('Got nonce: $nonce');

      // Now register the user with the nonce
      print(
          'Sending registration request to: ${AppConstants.registerEndpoint}');
      print('With parameters: username=$username, email=$email');

      final response = await _dioClient.post(
        AppConstants.registerEndpoint,
        queryParameters: {
          'username': username,
          'email': email,
          'user_pass': password,
          'nonce': nonce,
          'display_name': username, // Optional, using username as display name
          'notify': 'both', // Send notification to both admin and user
        },
      );

      // Log the full response for debugging
      print('Registration response: $response');

      // Check if the registration was successful
      if (response['status'] == 'ok') {
        // Check if there's a user object in the response
        if (response['user'] != null) {
          print('User created with ID: ${response['user']['id']}');
          // If the response contains user data, use it
          return UserModel(
            id: response['user']['id'] ?? 0,
            username: response['user']['username'] ?? username,
            email: response['user']['email'] ?? email,
            firstName: response['user']['firstname'] ?? '',
            lastName: response['user']['lastname'] ?? '',
            roles: ['subscriber'], // Default role
          );
        } else {
          print('No user data in response, creating basic user model');
          // Create a basic user model with the provided information
          return UserModel(
            id: 0, // We don't know the ID yet
            username: username,
            email: email,
            firstName: '',
            lastName: '',
            roles: ['subscriber'], // Default role
          );
        }
      } else if (response['error'] != null) {
        // If there's an error message in the response
        print('Registration error: ${response['error']}');
        throw ApiException(
            message: 'Registration failed: ${response['error']}');
      } else {
        print('Unknown registration error');
        throw ApiException(message: 'Registration failed: Unknown error');
      }
    } catch (e) {
      print('Registration exception: ${e.toString()}');
      throw ApiException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      // First, get a nonce for password reset
      print('Getting nonce for password reset');
      final nonceResponse = await _dioClient.get(
        '${AppConstants.baseUrl}/api/get_nonce/',
        queryParameters: {
          'controller': 'user',
          'method': 'retrieve_password',
        },
      );

      final nonce = nonceResponse['nonce'];
      print('Got nonce: $nonce');

      // Now send the password reset request
      print(
          'Sending password reset request to: ${AppConstants.forgotPasswordEndpoint}');
      print('With parameters: user_login=$email');

      // For JSON API User plugin, we need to use query parameters
      final response = await _dioClient.post(
        AppConstants.forgotPasswordEndpoint,
        queryParameters: {
          'user_login': email, // The plugin expects user_login, not email
          'nonce': nonce,
        },
      );

      print('Password reset response: $response');

      // Check if the password reset request was successful
      if (response['status'] != 'ok') {
        if (response['error'] != null) {
          print('Password reset error: ${response['error']}');
          throw ApiException(
              message: 'Password reset request failed: ${response['error']}');
        } else {
          print('Unknown password reset error');
          throw ApiException(
              message: 'Password reset request failed: Unknown error');
        }
      }
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
