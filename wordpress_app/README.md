# WordPress Flutter Integration App

> **IMPORTANT: NEVER PUSH TO GIT UNLESS EXPLICITLY REQUESTED BY THE USER**
> **ALL CODE MUST BE THOROUGHLY TESTED BEFORE COMMITTING**

A modern Flutter application that integrates with WordPress APIs, allowing users to log in, register, reset passwords, and interact with WordPress content directly within the app. The app serves as a proof of concept for leveraging WordPress as a backend while providing a seamless native mobile experience.

## Features

### Authentication
- **JWT Authentication**: Secure login using WordPress JWT Authentication
- **User Registration**: Register new users through WordPress
- **Password Reset**: Reset passwords through WordPress with email verification codes
- **Secure Storage**: Secure token storage for persistent login
- **Email Verification**: Email verification for new user registrations and password reset

### WordPress API Integration
- **User Profile Management**: View and update user profiles
- **Content Access**: Access posts, pages, and custom content types
- **Social Features**: Share and interact with content
- **Custom API Endpoints**: Extended WordPress functionality through custom endpoints

### Architecture
- **Clean Architecture**: Separation of concerns with domain, data, and presentation layers
- **BLoC Pattern**: Robust state management
- **Repository Pattern**: Data access abstraction
- **Dependency Injection**: Service locator pattern with GetIt

### UI/UX
- **Material Design 3**: Modern, clean interface following Material Design guidelines
- **Responsive Layouts**: Adapts to different screen sizes
- **Form Validation**: Comprehensive input validation with real-time feedback
- **Password Visibility Toggle**: Show/hide password with eye icon
- **Loading Indicators**: Visual feedback during network operations
- **Error Handling**: User-friendly error messages
- **Animations**: Smooth transitions between screens

## WordPress Configuration

### Required WordPress Plugins
- **JWT Authentication for WP-API**: Enables JWT token-based authentication
- **WP Mail SMTP**: Configured with login@djchucks.com for reliable email delivery
- **Advanced Custom Fields**: For extended content management
- **Custom Post Type UI**: For custom content types
- **JSON API**: Core controller activated for API access
- **WP Flutter Auth**: Custom plugin for email verification codes (password reset and registration)

### WordPress Settings
- **User Registration**: Enabled in Settings > General > "Anyone can register"
- **Default User Role**: Set to "Subscriber"
- **JWT Authentication**: Properly configured in wp-config.php and .htaccess

### Custom WordPress Plugin
The WP Flutter Auth plugin provides custom endpoints for email verification:

- **Password Reset Flow**:
  - `/wp-json/wp-flutter/v1/request-reset-code`: Sends verification code email
  - `/wp-json/wp-flutter/v1/verify-reset-code`: Verifies code and returns reset token
  - `/wp-json/wp-flutter/v1/reset-password`: Resets password using token

- **Registration Verification Flow**:
  - `/wp-json/wp-flutter/v1/request-registration-code`: Sends verification code email
  - `/wp-json/wp-flutter/v1/verify-registration`: Verifies registration code

## Authentication Flow

### Login Flow
1. User enters username/email and password
2. App sends credentials to JWT authentication endpoint
3. WordPress validates credentials and returns JWT token
4. App stores token securely and uses it for authenticated requests

### Registration Flow
1. User enters username, email, and password
2. App submits registration form to WordPress API
3. WordPress creates user (pending verification)
4. App requests verification code to be sent to user's email
5. User enters verification code in the app
6. App verifies code with WordPress to activate the account
7. After successful verification, user can log in with credentials

### Password Reset Flow
1. User enters email address
2. App submits password reset request to custom WordPress plugin endpoint
3. WordPress sends verification code email via WP Mail SMTP
4. User enters verification code in the app
5. App verifies code with WordPress and receives reset token
6. User creates new password and submits with reset token
7. After successful password reset, user is redirected to login screen
8. User can log in with new credentials

## API Endpoints

```dart
// Base URLs
static const String baseUrl = 'https://djchucks.com/tester';
static const String apiUrl = '$baseUrl/wp-json';
static const String jsonApiUrl = '$baseUrl/?json=';
static const String wpFlutterApiUrl = '$apiUrl/wp-flutter/v1';

// JWT Authentication endpoints
static const String loginEndpoint = '$apiUrl/jwt-auth/v1/token';
static const String userEndpoint = '$apiUrl/wp/v2/users/me';

// User management endpoints
static const String registerEndpoint = '$apiUrl/wp/v2/users';

// Custom WordPress Flutter Auth plugin endpoints
// Password reset endpoints
static const String requestResetCodeEndpoint = '$wpFlutterApiUrl/request-reset-code';
static const String verifyResetCodeEndpoint = '$wpFlutterApiUrl/verify-reset-code';
static const String resetPasswordEndpoint = '$wpFlutterApiUrl/reset-password';

// Registration verification endpoints
static const String requestRegistrationCodeEndpoint = '$wpFlutterApiUrl/request-registration-code';
static const String verifyRegistrationEndpoint = '$wpFlutterApiUrl/verify-registration';
```

## Project Structure

```
lib/
├── app/                  # App configuration and routes
├── core/                 # Core functionality
│   ├── constants/        # App constants and theme
│   ├── errors/           # Error handling
│   ├── network/          # Network layer
│   ├── storage/          # Local storage
│   ├── di/               # Dependency injection
│   └── utils/            # Utilities
├── data/                 # Data layer
│   ├── datasources/      # Remote and local data sources
│   ├── models/           # Data models
│   └── repositories/     # Repository implementations
├── domain/               # Domain layer
│   ├── entities/         # Domain entities
│   ├── repositories/     # Repository interfaces
│   ├── usecases/         # Use cases
│   └── blocs/            # BLoC state management
└── presentation/         # Presentation layer
    ├── pages/            # App screens
    └── widgets/          # Reusable widgets
```

## Architecture

The app follows Clean Architecture principles with three main layers:

1. **Presentation Layer**: UI components and BLoC state management
2. **Domain Layer**: Business logic and use cases
3. **Data Layer**: Data sources and repositories

## Key Packages

- **flutter_bloc**: State management
- **dio**: HTTP client for API requests
- **flutter_secure_storage**: Secure storage for JWT tokens
- **get_it**: Dependency injection
- **equatable**: Value equality for models
- **formz**: Form validation
- **flutter_svg**: SVG rendering for icons
- **shared_preferences**: Local storage for app settings

## Development Status

- ✅ WordPress backend configured with JWT Authentication
- ✅ WP Mail SMTP configured with login@djchucks.com
- ✅ Login functionality implemented and tested
- ✅ Logout functionality implemented and tested
- ✅ User registration implemented and tested
- ✅ Password reset with email verification implemented and tested
- ✅ Email verification code mechanism for password reset working
- ✅ Navigation after password reset fixed
- 🔄 Registration email verification in progress
- ⬜ User profile management
- ⬜ Content access and display
- ⬜ Social features implementation
- ⬜ Error handling improvements
- ⬜ UI polish and refinements

## Next Steps

1. Complete the email verification code mechanism for registration
2. Fix iOS keychain persistence behavior in debug mode
3. Implement user profile management (view and update profile)
4. Add content access features (posts, pages, custom content types)
5. Implement social features (comments, likes, shares)
6. Improve error handling for network issues
7. Add comprehensive unit and widget tests
8. Expand WordPress API integration with additional features

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- WordPress site with required plugins
- DirectAdmin email configuration

### Installation

1. Clone the repository
   ```
   git clone https://github.com/Catskill909/wordpress-login.git
   ```
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

## Recent Updates

### Password Reset Flow Improvements (July 2024)
- Implemented complete password reset flow with email verification codes
- Fixed navigation issue after successful password reset
- Added proper GoRouter integration for consistent navigation
- Ensured login screen properly redirects to home screen after successful login
- Documented iOS keychain persistence behavior

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
   - Ensure the custom WordPress plugin endpoints are working

4. **iOS Keychain Persistence**
   - On iOS, keychain data persists between app installations
   - This is standard iOS behavior for security reasons
   - In debug mode, users may be automatically logged in after reinstalling
   - A future update will clear auth data on first launch in debug mode
