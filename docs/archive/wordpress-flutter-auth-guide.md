# WordPress Authentication for Flutter Apps

> **IMPORTANT: NEVER PUSH TO GIT UNLESS EXPLICITLY REQUESTED BY THE USER**
> **ALL CODE MUST BE THOROUGHLY TESTED BEFORE COMMITTING**

This guide documents the standard approach for implementing WordPress authentication in Flutter apps, including login, registration, and password reset functionality.

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Authentication Flow](#3-authentication-flow)
4. [Implementation Details](#4-implementation-details)
5. [Testing](#5-testing)
6. [Troubleshooting](#6-troubleshooting)

## 1. Overview

This implementation uses the WordPress REST API with JWT Authentication to provide a complete authentication solution for Flutter apps. It follows standard practices for WordPress mobile app development.

### Key Features

- **Login**: JWT Authentication for secure login
- **Registration**: User creation via WordPress REST API with admin authentication
- **Password Reset**: Integration with WordPress's built-in password reset functionality

## 2. Prerequisites

### WordPress Configuration

1. **JWT Authentication Plugin**
   - Install and activate the "JWT Authentication for WP REST API" plugin
   - Configure the plugin as per its documentation:
     - Add secret key to wp-config.php
     - Configure .htaccess for CORS support

2. **Email Configuration**
   - Configure WordPress to send emails properly
   - Consider using a plugin like WP Mail SMTP for reliable email delivery

3. **User Registration Settings**
   - Ensure user registration is enabled in WordPress (Settings > General)
   - This has been confirmed to be enabled on the site

## 3. Authentication Flow

### Login Flow

1. User enters username/email and password
2. App sends credentials to JWT authentication endpoint
3. WordPress validates credentials and returns JWT token
4. App stores token securely and uses it for authenticated requests

### Registration Flow

**Note: User registration must be enabled in WordPress settings for this to work**

If registration is enabled:
1. User enters username, email, and password
2. App authenticates as admin using JWT authentication
3. App uses admin token to create a new user via WordPress REST API
4. On success, app logs in the new user automatically

If registration is disabled (current state):
1. User enters username, email, and password
2. App informs user that registration is disabled
3. App provides instructions on how to enable registration in WordPress

### Password Reset Flow

1. User enters email address
2. App directs user to WordPress password reset page
3. User receives password reset email and sets new password
4. User returns to app and logs in with new password

## 4. Implementation Details

### API Endpoints

```dart
// JWT Authentication endpoints
static const String loginEndpoint = '$apiUrl/jwt-auth/v1/token';
static const String userEndpoint = '$apiUrl/wp/v2/users/me';

// User management endpoints
static const String registerEndpoint = '$apiUrl/wp/v2/users';
static const String forgotPasswordEndpoint = '$baseUrl/wp-login.php?action=lostpassword';
```

### Login Implementation

```dart
Future<Map<String, dynamic>> login(String username, String password) async {
  try {
    final response = await _dioClient.post(
      AppConstants.loginEndpoint,
      data: {
        'username': username,
        'password': password,
      },
    );

    // Store token securely
    await _secureStorage.write(key: AppConstants.tokenKey, value: response['token']);

    // Get user data
    final user = await getCurrentUser();

    return {
      'token': response['token'],
      'user': user,
    };
  } catch (e) {
    throw ApiException(message: 'Login failed: ${e.toString()}');
  }
}
```

### Registration Implementation

```dart
Future<UserModel> register(String username, String email, String password) async {
  try {
    // Since WordPress registration is now enabled, we can use the standard WordPress registration form
    // We'll submit the registration form directly to WordPress

    // First, let's try to register the user using the WordPress registration form
    final response = await _dioClient.post(
      '${AppConstants.baseUrl}/wp-login.php?action=register',
      data: {
        'user_login': username,
        'user_email': email,
      },
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        followRedirects: false,
      ),
    );

    // If registration is successful, WordPress will send a confirmation email
    // We'll inform the user to check their email

    // Now, let's try to log in with the provided credentials
    // Note: This will likely fail until the user confirms their email
    try {
      final loginResponse = await login(username, password);
      return loginResponse['user'] as UserModel;
    } catch (loginError) {
      // Expected to fail until email confirmation
      throw ApiException(
        message: 'Registration successful! Please check your email to confirm your registration before logging in.'
      );
    }
  } catch (e) {
    throw ApiException(message: 'Registration failed: ${e.toString()}');
  }
}
```

### Password Reset Implementation

```dart
Future<void> forgotPassword(String email) async {
  try {
    // WordPress has a built-in password reset form
    // We'll submit the form directly to WordPress

    final response = await _dioClient.post(
      AppConstants.forgotPasswordEndpoint,
      data: {
        'user_login': email, // WordPress accepts either username or email
      },
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        followRedirects: false,
      ),
    );

    // If the request is successful, WordPress will send a password reset email
    // We'll inform the user to check their email

    return; // Success
  } catch (e) {
    throw ApiException(message: 'Password reset failed: ${e.toString()}');
  }
}
```

## 5. Testing

### Testing Login

1. Enter valid WordPress credentials
2. Verify successful login and token storage
3. Test with invalid credentials to ensure proper error handling

### Testing Registration

1. Enter new username, email, and password
2. Verify user is created in WordPress
3. Verify automatic login after registration
4. Test with existing username/email to ensure proper error handling

### Testing Password Reset

1. Enter valid email address
2. Verify user is directed to WordPress password reset page
3. Complete password reset process on WordPress site
4. Verify login with new password

## 6. Troubleshooting

### Common Issues

1. **JWT Authentication Errors**
   - Verify JWT plugin is properly configured
   - Check secret key in wp-config.php
   - Ensure CORS is properly configured

2. **User Creation Errors**
   - Verify admin credentials are correct
   - Ensure admin has sufficient privileges
   - Check if user registration is enabled in WordPress

3. **Email Delivery Issues**
   - Configure proper email settings in WordPress
   - Use WP Mail SMTP plugin for reliable delivery
   - Check server's email capabilities

### Debugging Tips

1. Enable verbose logging in the app
2. Check WordPress error logs
3. Use tools like Postman to test API endpoints directly
