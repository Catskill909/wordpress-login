class AppConstants {
  // API
  static const String baseUrl = 'https://yourdomain.com';
  static const String apiUrl = '$baseUrl/wp-json';
  static const String loginEndpoint = '$apiUrl/jwt-auth/v1/token';
  static const String registerEndpoint = '$apiUrl/wp/v2/users/register';
  static const String forgotPasswordEndpoint = '$apiUrl/wp-json-api/v1/users/lost_password';
  static const String userEndpoint = '$apiUrl/wp/v2/users/me';
  
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
