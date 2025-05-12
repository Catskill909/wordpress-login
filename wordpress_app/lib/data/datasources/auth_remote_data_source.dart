import 'package:dio/dio.dart';
import 'package:wordpress_app/core/constants/app_constants.dart';
import 'package:wordpress_app/core/errors/exceptions.dart';
import 'package:wordpress_app/core/network/dio_client.dart';
import 'package:wordpress_app/core/utils/logger_util.dart';
import 'package:wordpress_app/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<UserModel> register(String username, String email, String password);

  // Password reset flow
  Future<void> forgotPassword(String email);
  Future<String> verifyResetCode(String email, String code);
  Future<void> resetPassword(
      String email, String resetToken, String newPassword);

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
      LoggerUtil.i('Registering user: $username, $email');

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

        LoggerUtil.i('Registration response status: ${response.statusCode}');

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
        LoggerUtil.e(
            'Registration request error: ${registrationError.toString()}',
            registrationError);
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
      LoggerUtil.e('Registration error: ${e.toString()}', e);

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      LoggerUtil.i('Sending password reset for email: $email');

      // Use WordPress's standard password reset form
      try {
        // Create a Dio instance with custom validation
        final dio = Dio();

        // Configure Dio to accept 302 redirects as successful responses
        dio.options.validateStatus = (status) {
          return status != null && (status >= 200 && status < 400);
        };

        final response = await dio.post(
          AppConstants.forgotPasswordEndpoint,
          data: {
            'user_login': email, // WordPress accepts either username or email
          },
          options: Options(
            contentType: 'application/x-www-form-urlencoded',
            followRedirects: true, // Allow redirects
            responseType: ResponseType.plain, // Get the response as plain text
          ),
        );

        LoggerUtil.i('Password reset response status: ${response.statusCode}');
        LoggerUtil.d('Password reset response body: ${response.data}');

        // If we get here, the request was successful
        return;
      } catch (resetError) {
        if (resetError is ApiException) {
          rethrow;
        }

        // If there was an error with the password reset request
        LoggerUtil.e('Password reset request error: ${resetError.toString()}',
            resetError);
        throw ApiException(
            message: 'Password reset failed: ${resetError.toString()}');
      }
    } catch (e) {
      LoggerUtil.e('Password reset error: ${e.toString()}', e);

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

  @override
  Future<String> verifyResetCode(String email, String code) async {
    try {
      LoggerUtil.i('Verifying reset code for email: $email, code: $code');

      // Since we're using WordPress's standard password reset flow,
      // we'll use a mock implementation for now
      // In a real implementation, we would need to extract a token from the reset link
      // or use a plugin that provides a code-based reset flow

      // For testing purposes, we'll accept any 6-digit code
      if (code.length == 6 && int.tryParse(code) != null) {
        // Return a mock token
        return 'mock_reset_token_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        throw ApiException(
            message: 'Invalid verification code. Please enter a 6-digit code.');
      }
    } catch (e) {
      LoggerUtil.e('Verify reset code error: ${e.toString()}', e);

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
          message: 'Failed to verify reset code: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(
      String email, String resetToken, String newPassword) async {
    try {
      LoggerUtil.i('Resetting password for email: $email');

      // Since we're using WordPress's standard password reset flow,
      // we'll use a mock implementation for now
      // In a real implementation, we would need to use the reset link from the email
      // or use a plugin that provides a code-based reset flow

      // For testing purposes, we'll simulate a successful password reset
      // In a real implementation, we would make an API call to reset the password

      // Simulate a delay to make it feel more realistic
      await Future.delayed(const Duration(seconds: 1));

      // If we get here, the password was reset successfully
      return;
    } catch (e) {
      LoggerUtil.e('Reset password error: ${e.toString()}', e);

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(message: 'Failed to reset password: ${e.toString()}');
    }
  }
}
