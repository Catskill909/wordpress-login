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

      // Try direct registration first (this might work if the site has registration enabled)
      try {
        final response = await _dioClient.post(
          '${AppConstants.baseUrl}/wp-json/wp/v2/users/register',
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

        print('User registration response: $response');

        if (response != null && response['id'] != null) {
          print('User created with ID: ${response['id']}');

          // Now log in the user to get their own token
          final loginResponse = await login(username, password);

          return loginResponse['user'] as UserModel;
        }
      } catch (directRegError) {
        print(
            'Direct registration failed, trying alternative method: ${directRegError.toString()}');

        // If direct registration fails, try using the WordPress registration form
        // This is a fallback that will inform the user to register on the WordPress site
        final registrationUrl =
            '${AppConstants.baseUrl}/wp-login.php?action=register';

        throw ApiException(
            message:
                'Registration failed: The WordPress site requires admin privileges for registration.\n\n' +
                    'Please register at: $registrationUrl\n\n' +
                    'After registering, you can log in using the app.');
      }

      throw ApiException(
          message: 'Registration failed: Invalid response from server');
    } catch (e) {
      print('Registration error: ${e.toString()}');

      if (e is DioException && e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData['message'] != null) {
          throw ApiException(
              message: 'Registration failed: ${errorData['message']}');
        }
      }

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

      // Try direct password reset first
      try {
        final response = await _dioClient.post(
          '${AppConstants.baseUrl}/wp-json/wp/v2/users/lostpassword',
          data: {
            'email': email,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        print('Password reset response: $response');

        // Check if the password reset request was successful
        if (response != null && response['success'] != null) {
          // Password reset email sent successfully
          return;
        }
      } catch (directResetError) {
        print(
            'Direct password reset failed, using fallback: ${directResetError.toString()}');

        // If direct password reset fails, use the WordPress password reset form
        final resetUrl =
            '${AppConstants.baseUrl}/wp-login.php?action=lostpassword';

        throw ApiException(
            message:
                'Password reset failed: The WordPress site requires admin privileges for password reset.\n\n'
                'Please go to: $resetUrl\n\n'
                'Enter your email: $email');
      }

      throw ApiException(
          message: 'Password reset failed: Invalid response from server');
    } catch (e) {
      print('Password reset error: ${e.toString()}');

      if (e is DioException && e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData['message'] != null) {
          throw ApiException(
              message: 'Password reset failed: ${errorData['message']}');
        }
      }

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
