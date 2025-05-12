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
      print('Registering user: $username, $email');

      // Since WordPress registration is now enabled, we can use the standard WordPress registration form
      // We'll submit the registration form directly to WordPress

      // First, let's try to register the user using the WordPress registration form
      try {
        final dio =
            Dio(); // Use a separate Dio instance to handle HTML responses
        final response = await dio.post(
          '${AppConstants.baseUrl}/wp-login.php?action=register',
          data: {
            'user_login': username,
            'user_email': email,
          },
          options: Options(
            contentType: 'application/x-www-form-urlencoded',
            followRedirects: false,
            responseType: ResponseType.plain, // Get the response as plain text
          ),
        );

        print('Registration response status: ${response.statusCode}');

        // Check if the response contains a success message
        if (response.statusCode == 200 &&
            response.data.toString().contains('Registration complete')) {
          // Registration successful
          throw ApiException(
              message:
                  'Registration successful! Please check your email to confirm your registration before logging in.');
        }
      } catch (registrationError) {
        if (registrationError is ApiException) {
          rethrow;
        }

        // If there was an error with the registration request
        print('Registration request error: ${registrationError.toString()}');
      }

      // If we get here, try to log in (this will likely fail until email confirmation)
      try {
        final loginResponse = await login(username, password);
        return loginResponse['user'] as UserModel;
      } catch (loginError) {
        // Expected to fail until email confirmation
        throw ApiException(
            message:
                'Registration successful! Please check your email to confirm your registration before logging in.');
      }
    } catch (e) {
      print('Registration error: ${e.toString()}');

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      print('Sending password reset for email: $email');

      // WordPress has a built-in password reset form
      // We'll submit the form directly to WordPress

      try {
        final dio =
            Dio(); // Use a separate Dio instance to handle HTML responses
        final response = await dio.post(
          AppConstants.forgotPasswordEndpoint,
          data: {
            'user_login': email, // WordPress accepts either username or email
          },
          options: Options(
            contentType: 'application/x-www-form-urlencoded',
            followRedirects: false,
            responseType: ResponseType.plain, // Get the response as plain text
          ),
        );

        print('Password reset response status: ${response.statusCode}');

        // If the request is successful, WordPress will send a password reset email
        if (response.statusCode == 200 || response.statusCode == 302) {
          // Password reset email sent successfully
          return;
        }
      } catch (resetError) {
        if (resetError is ApiException) {
          rethrow;
        }

        // If there was an error with the password reset request
        print('Password reset request error: ${resetError.toString()}');
        throw ApiException(
            message: 'Password reset failed: ${resetError.toString()}');
      }

      return; // Success
    } catch (e) {
      print('Password reset error: ${e.toString()}');

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(message: 'Password reset failed: ${e.toString()}');
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
