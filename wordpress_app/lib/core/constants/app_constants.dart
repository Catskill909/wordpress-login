class AppConstants {
  // API
  static const String baseUrl = 'https://djchucks.com/tester';
  static const String apiUrl = '$baseUrl/wp-json';
  static const String jsonApiUrl = '$baseUrl/?json=';

  // JWT Authentication endpoints
  static const String loginEndpoint = '$apiUrl/jwt-auth/v1/token';
  static const String userEndpoint = '$apiUrl/wp/v2/users/me';

  // API endpoints
  static const String registerEndpoint = '$apiUrl/wp/v2/users';
  static const String forgotPasswordEndpoint =
      '$apiUrl/wp/v2/users/lostpassword';

  // Admin credentials for creating users (only for demo purposes)
  // In a production app, these would be stored securely or retrieved from environment variables
  static const String adminUsername = 'admin';
  static const String adminPassword =
      'admin123'; // Using a default password for testing

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
