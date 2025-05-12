class AppConstants {
  // API
  static const String baseUrl = 'https://djchucks.com/tester';
  static const String apiUrl = '$baseUrl/wp-json';
  static const String jsonApiUrl = '$baseUrl/?json=';
  static const String wpFlutterApiUrl = '$apiUrl/wp-flutter/v1';

  // JWT Authentication endpoints
  static const String loginEndpoint = '$apiUrl/jwt-auth/v1/token';
  static const String userEndpoint = '$apiUrl/wp/v2/users/me';

  // API endpoints
  static const String registerEndpoint = '$apiUrl/wp/v2/users';

  // Custom WordPress Flutter Auth plugin endpoints
  // Password reset endpoints
  static const String requestResetCodeEndpoint =
      '$wpFlutterApiUrl/request-reset-code';
  static const String verifyResetCodeEndpoint =
      '$wpFlutterApiUrl/verify-reset-code';
  static const String resetPasswordEndpoint = '$wpFlutterApiUrl/reset-password';

  // Registration verification endpoints
  static const String requestRegistrationCodeEndpoint =
      '$wpFlutterApiUrl/request-registration-code';
  static const String verifyRegistrationEndpoint =
      '$wpFlutterApiUrl/verify-registration';

  // Legacy endpoints (kept for reference)
  static const String forgotPasswordEndpoint =
      '$baseUrl/wp-login.php?action=lostpassword';

  // Admin credentials for user creation (these should be stored securely in a production app)
  static const String adminUsername = 'admin';
  static const String adminPassword =
      'admin123'; // Replace with actual admin password

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';

  // Timeouts
  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds

  // Pagination
  static const int defaultPageSize = 10;
}
