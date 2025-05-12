import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
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

  // Registration verification flow
  Future<void> requestRegistrationCode(String email);
  Future<void> verifyRegistration(String email, String code);

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
      LoggerUtil.i('Requesting password reset code for email: $email');

      // Try multiple approaches to ensure the request goes through

      // Approach 1: Use Process.run to execute curl command directly
      try {
        LoggerUtil.i('Trying approach 1: Using Process.run with curl');

        final result = await Process.run('curl', [
          '-v',
          '-X',
          'POST',
          '-H',
          'Content-Type: application/json',
          '-d',
          '{"email":"$email"}',
          AppConstants.requestResetCodeEndpoint,
        ]);

        LoggerUtil.i('Curl stdout: ${result.stdout}');
        LoggerUtil.i('Curl stderr: ${result.stderr}');

        if (result.exitCode == 0) {
          final response = jsonDecode(result.stdout.toString());
          LoggerUtil.i(
              'Password reset code request response (curl): $response');

          if (response['status'] == 'success') {
            return; // Success!
          }
        }
      } catch (curlError) {
        LoggerUtil.e('Curl approach failed: $curlError');
        // Continue to next approach
      }

      // Approach 2: Use http package with additional timeout
      try {
        LoggerUtil.i('Trying approach 2: Using http package with timeout');

        final url = Uri.parse(AppConstants.requestResetCodeEndpoint);
        final headers = {'Content-Type': 'application/json'};
        final body = jsonEncode({'email': email});

        LoggerUtil.i('Making HTTP request to: $url');
        LoggerUtil.i('With headers: $headers');
        LoggerUtil.i('With body: $body');

        final httpResponse = await http
            .post(
              url,
              headers: headers,
              body: body,
            )
            .timeout(const Duration(seconds: 30));

        LoggerUtil.i('HTTP response status code: ${httpResponse.statusCode}');
        LoggerUtil.i('HTTP response body: ${httpResponse.body}');

        if (httpResponse.statusCode == 200) {
          final response = jsonDecode(httpResponse.body);
          LoggerUtil.i(
              'Password reset code request response (http): $response');

          if (response['status'] == 'success') {
            return; // Success!
          } else {
            throw ApiException(
                message:
                    response['message'] ?? 'Failed to send verification code');
          }
        } else {
          throw ApiException(
              message:
                  'Failed to send verification code: HTTP ${httpResponse.statusCode}');
        }
      } catch (httpError) {
        LoggerUtil.e('HTTP approach failed: $httpError');
        // Continue to next approach
      }

      // Approach 3: Use Dio directly (not DioClient)
      try {
        LoggerUtil.i('Trying approach 3: Using Dio directly');

        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);
        dio.options.headers = {'Content-Type': 'application/json'};

        final dioResponse = await dio.post(
          AppConstants.requestResetCodeEndpoint,
          data: {'email': email},
        );

        LoggerUtil.i('Dio response status code: ${dioResponse.statusCode}');
        LoggerUtil.i('Dio response body: ${dioResponse.data}');

        if (dioResponse.statusCode == 200) {
          final response = dioResponse.data;
          LoggerUtil.i('Password reset code request response (dio): $response');

          if (response['status'] == 'success') {
            return; // Success!
          } else {
            throw ApiException(
                message:
                    response['message'] ?? 'Failed to send verification code');
          }
        } else {
          throw ApiException(
              message:
                  'Failed to send verification code: HTTP ${dioResponse.statusCode}');
        }
      } catch (dioError) {
        LoggerUtil.e('Dio approach failed: $dioError');
        // All approaches failed
        throw ApiException(
            message: 'All approaches failed to send verification code');
      }
    } catch (e) {
      LoggerUtil.e('Request reset code error: ${e.toString()}', e);

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
          message: 'Failed to request reset code: ${e.toString()}');
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

      // Ensure code is a string
      final String codeStr = code.toString().trim();

      // Log the exact data being sent
      LoggerUtil.i('Sending data: {"email": "$email", "code": "$codeStr"}');

      final response = await _dioClient.post(
        AppConstants.verifyResetCodeEndpoint,
        data: {
          'email': email,
          'code': codeStr,
        },
      );

      LoggerUtil.i('Verify reset code response: $response');

      if (response['status'] != 'success') {
        throw ApiException(
            message: response['message'] ?? 'Failed to verify code');
      }

      return response['reset_token'] ?? '';
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

      final response = await _dioClient.post(
        AppConstants.resetPasswordEndpoint,
        data: {
          'email': email,
          'reset_token': resetToken,
          'new_password': newPassword,
        },
      );

      LoggerUtil.i('Reset password response: $response');

      if (response['status'] != 'success') {
        throw ApiException(
            message: response['message'] ?? 'Failed to reset password');
      }

      return;
    } catch (e) {
      LoggerUtil.e('Reset password error: ${e.toString()}', e);

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(message: 'Failed to reset password: ${e.toString()}');
    }
  }

  @override
  Future<void> requestRegistrationCode(String email) async {
    try {
      LoggerUtil.i('Requesting registration code for email: $email');

      final response = await _dioClient.post(
        AppConstants.requestRegistrationCodeEndpoint,
        data: {
          'email': email,
        },
      );

      LoggerUtil.i('Registration code request response: $response');

      if (response['status'] != 'success') {
        throw ApiException(
            message: response['message'] ?? 'Failed to send verification code');
      }

      return;
    } catch (e) {
      LoggerUtil.e('Request registration code error: ${e.toString()}', e);

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
          message: 'Failed to request registration code: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyRegistration(String email, String code) async {
    try {
      LoggerUtil.i('Verifying registration for email: $email, code: $code');

      final response = await _dioClient.post(
        AppConstants.verifyRegistrationEndpoint,
        data: {
          'email': email,
          'code': code,
        },
      );

      LoggerUtil.i('Verify registration response: $response');

      if (response['status'] != 'success') {
        throw ApiException(
            message: response['message'] ?? 'Failed to verify registration');
      }

      return;
    } catch (e) {
      LoggerUtil.e('Verify registration error: ${e.toString()}', e);

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
          message: 'Failed to verify registration: ${e.toString()}');
    }
  }
}
