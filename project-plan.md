# WordPress Flutter Integration App Project Plan

> **IMPORTANT: NEVER PUSH TO GIT UNLESS EXPLICITLY REQUESTED BY THE USER**
> **ALL CODE MUST BE THOROUGHLY TESTED BEFORE COMMITTING**

This document outlines the complete project plan for the WordPress Flutter Integration App, including completed tasks and next steps.

## Project Overview

A Flutter mobile application that integrates with WordPress APIs, allowing users to log in, register, reset passwords, and interact with WordPress content directly within the app. The app serves as a proof of concept for leveraging WordPress as a backend while providing a seamless native mobile experience.

## Completed Tasks

### 1. ✅ WordPress Backend Setup

- ✅ Install WordPress on hosting
- ✅ Install and configure required plugins:
  - ✅ JWT Authentication for WP-API
  - ✅ WP Mail SMTP
  - ✅ Advanced Custom Fields
  - ✅ Custom Post Type UI
  - ✅ JSON API (core controller activated)
- ✅ Configure WordPress settings:
  - ✅ Enable user registration
  - ✅ Set default user role to "Subscriber"
  - ✅ Configure JWT Authentication in wp-config.php and .htaccess

### 2. ✅ Flutter App Setup

- ✅ Create Flutter project with clean architecture
- ✅ Set up project structure
  - ✅ Core layer (constants, errors, network, storage, utils)
  - ✅ Data layer (datasources, models, repositories)
  - ✅ Domain layer (entities, repositories, usecases, blocs)
  - ✅ Presentation layer (pages, widgets)
- ✅ Configure dependencies in pubspec.yaml
  - ✅ flutter_bloc for state management
  - ✅ dio for HTTP requests
  - ✅ flutter_secure_storage for token storage
  - ✅ get_it for dependency injection
  - ✅ equatable for value equality
  - ✅ formz for form validation
- ✅ Implement Material Design theme
  - ✅ Custom color scheme
  - ✅ Typography
  - ✅ Input decorations
- ✅ Create core utilities and constants
  - ✅ API endpoints
  - ✅ Storage keys
  - ✅ Error handling

### 3. ✅ Authentication Implementation

#### 3.1 ✅ Login Functionality

- ✅ Create login UI with form validation
- ✅ Implement JWT authentication with WordPress
- ✅ Store JWT token securely
- ✅ Handle login errors
- ✅ Implement persistent login
- ✅ Create logout functionality

#### 3.2 ✅ Registration Functionality

- ✅ Create registration UI with form validation
- ✅ Implement user registration with WordPress
- ✅ Handle registration errors
- ✅ Show success message with email verification instructions
- ✅ Test registration flow

#### 3.3 ✅ Password Reset Functionality

- ✅ Create password reset UI with form validation
- ✅ Implement password reset with WordPress
- ✅ Handle password reset errors
- ✅ Show success message with reset instructions
- ✅ Test password reset flow

## Current Status

- ✅ WordPress backend is fully configured
- ✅ JWT Authentication is working correctly
- ✅ WP Mail SMTP is configured with login@djchucks.com
- ✅ Login and logout functionality is working
- ✅ User registration is working (email verification required)
- ✅ Password reset is implemented (needs testing)
- 🔄 Email verification code mechanism in progress
- ⬜ WordPress content integration features
- ⬜ User profile management
- ⬜ Social features implementation

## Next Steps

### 1. 🔄 Email Verification Code Implementation

- 🔄 Implement email verification code mechanism for password reset
- 🔄 Implement email verification code mechanism for registration
- ⬜ Create UI for entering verification codes
- ⬜ Implement verification code validation
- ⬜ Add resend code functionality
- ⬜ Test the complete email verification flow
- ⬜ Document the email verification process

### 2. 🔄 WordPress Content Integration

- ⬜ Implement post listing functionality
- ⬜ Implement post detail view
- ⬜ Add support for custom post types
- ⬜ Implement content search
- ⬜ Add content filtering and sorting
- ⬜ Implement content caching for offline access

### 3. 🔄 User Profile Management

- ⬜ Create profile view screen
- ⬜ Implement profile editing functionality
- ⬜ Add profile picture upload
- ⬜ Implement user settings
- ⬜ Add account management options

### 3. 🔄 Error Handling Improvements

- ⬜ Implement better error messages for network issues
- ⬜ Add retry functionality for failed requests
- ⬜ Improve validation error messages
- ⬜ Handle edge cases (e.g., account locked, server down)

### 4. 🔄 UI Enhancements

- ⬜ Add loading indicators during authentication
  - ⬜ Circular progress indicator during login
  - ⬜ Circular progress indicator during registration
  - ⬜ Circular progress indicator during password reset
- ⬜ Implement remember me functionality
  - ⬜ Add remember me checkbox to login screen
  - ⬜ Store credentials securely if remember me is checked
  - ⬜ Auto-fill credentials on app restart
- ⬜ Improve form field validation feedback
  - ⬜ Real-time validation for email format
  - ⬜ Password strength indicator
  - ⬜ Username availability check
- ⬜ Add animations for smoother transitions
  - ⬜ Page transitions
  - ⬜ Form field focus animations
  - ⬜ Button press animations
- ⬜ Ensure responsive design for different screen sizes
  - ⬜ Test on various screen sizes
  - ⬜ Implement adaptive layouts
  - ⬜ Adjust font sizes for different devices

### 5. 🔄 Testing

#### 5.1 🔄 Unit Testing
- ⬜ Write unit tests for authentication logic
  - ⬜ Test login functionality
  - ⬜ Test registration functionality
  - ⬜ Test password reset functionality
- ⬜ Write unit tests for BLoC logic
  - ⬜ Test AuthBloc states and events
  - ⬜ Test error handling
  - ⬜ Test edge cases

#### 5.2 🔄 Widget Testing
- ⬜ Write widget tests for UI components
  - ⬜ Test form validation
  - ⬜ Test password visibility toggle
  - ⬜ Test error message display
- ⬜ Test screen navigation
  - ⬜ Test navigation between login, registration, and password reset screens
  - ⬜ Test navigation to home screen after successful login

#### 5.3 🔄 Integration Testing
- ⬜ Write integration tests for complete flows
  - ⬜ Test complete login flow
  - ⬜ Test complete registration flow
  - ⬜ Test complete password reset flow
- ⬜ Test on multiple devices and screen sizes
  - ⬜ Test on phones (various sizes)
  - ⬜ Test on tablets
  - ⬜ Test on web

### 6. 🔄 Documentation

#### 6.1 🔄 Technical Documentation
- ⬜ Update API documentation
  - ⬜ Document all API endpoints
  - ⬜ Document request and response formats
  - ⬜ Document authentication requirements
- ⬜ Document code architecture
  - ⬜ Document clean architecture implementation
  - ⬜ Document BLoC pattern usage
  - ⬜ Document dependency injection setup

#### 6.2 🔄 User Documentation
- ⬜ Create user guide
  - ⬜ Document login process
  - ⬜ Document registration process
  - ⬜ Document password reset process
- ⬜ Create troubleshooting guide
  - ⬜ Document common issues and solutions
  - ⬜ Document error messages and their meanings

#### 6.3 🔄 Development Documentation
- ⬜ Document testing procedures
  - ⬜ Document unit testing approach
  - ⬜ Document widget testing approach
  - ⬜ Document integration testing approach
- ⬜ Create deployment guide
  - ⬜ Document build process
  - ⬜ Document release process
  - ⬜ Document version management

## Implementation Details

### WordPress Authentication Endpoints

```dart
// Base URLs
static const String baseUrl = 'https://djchucks.com/tester';
static const String apiUrl = '$baseUrl/wp-json';

// JWT Authentication endpoints
static const String loginEndpoint = '$apiUrl/jwt-auth/v1/token';
static const String userEndpoint = '$apiUrl/wp/v2/users/me';

// User management endpoints
static const String registerEndpoint = '$baseUrl/wp-login.php?action=register';
static const String forgotPasswordEndpoint = '$baseUrl/wp-login.php?action=lostpassword';
```

### Authentication Flow

#### Login Flow

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

#### Registration Flow

```dart
Future<UserModel> register(String username, String email, String password) async {
  try {
    final dio = Dio(); // Use a separate Dio instance to handle HTML responses
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

    // Check if the response contains a success message
    if (response.statusCode == 200 &&
        response.data.toString().contains('Registration complete')) {
      // Registration successful
      throw ApiException(
          message:
              'Registration successful! Please check your email to confirm your registration before logging in.');
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
    throw ApiException(message: 'Registration failed: ${e.toString()}');
  }
}
```

#### Password Reset Flow

```dart
Future<void> forgotPassword(String email) async {
  try {
    final dio = Dio(); // Use a separate Dio instance to handle HTML responses
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

    // If the request is successful, WordPress will send a password reset email
    if (response.statusCode == 200 || response.statusCode == 302) {
      // Password reset email sent successfully
      return;
    }
  } catch (e) {
    throw ApiException(message: 'Password reset failed: ${e.toString()}');
  }
}
```

## Testing Procedures

### Manual Testing

1. **Login Testing**
   - Test with valid credentials
   - Test with invalid credentials
   - Test with empty fields

2. **Registration Testing**
   - Test with new username and email
   - Test with existing username
   - Test with existing email
   - Test with invalid email format
   - Test with password mismatch

3. **Password Reset Testing**
   - Test with valid email
   - Test with invalid email
   - Test with non-existent email

## Troubleshooting

### Common Issues

1. **JWT Authentication Errors**
   - Verify JWT plugin is properly configured
   - Check secret key in wp-config.php
   - Ensure CORS is properly configured

2. **Registration Issues**
   - Verify user registration is enabled in WordPress
   - Check if email confirmation is required
   - Verify email delivery is working

3. **Password Reset Issues**
   - Check if WP Mail SMTP is properly configured
   - Verify email delivery is working
   - Check spam folder for reset emails
