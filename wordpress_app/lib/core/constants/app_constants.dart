class AppConstants {
  // API
  static const String baseUrl = 'https://djchucks.com/tester';
  static const String apiUrl = '$baseUrl/wp-json';
  static const String jsonApiUrl = '$baseUrl/?json=';

  // JWT Authentication endpoints
  static const String loginEndpoint = '$apiUrl/jwt-auth/v1/token';
  static const String userEndpoint = '$apiUrl/wp/v2/users/me';

  // Since the User controller is not activated and REST API requires admin privileges,
  // we'll use WordPress's built-in registration and password reset pages
  static const String registerEndpoint =
      '$baseUrl/wp-login.php?action=register';
  static const String forgotPasswordEndpoint =
      '$baseUrl/wp-login.php?action=lostpassword';

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
