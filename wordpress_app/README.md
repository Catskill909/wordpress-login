# WordPress Flutter Authentication App

> **IMPORTANT: NEVER PUSH TO GIT UNLESS EXPLICITLY REQUESTED BY THE USER**
> **ALL CODE MUST BE THOROUGHLY TESTED BEFORE COMMITTING**

A modern Flutter application that integrates with WordPress authentication, allowing users to log in, register, and reset passwords directly within the app.

## Features

### Authentication
- **JWT Authentication**: Secure login using WordPress JWT Authentication
- **User Registration**: Register new users through WordPress
- **Password Reset**: Reset passwords through WordPress
- **Secure Storage**: Secure token storage for persistent login
- **Email Verification**: Email verification for new user registrations

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

### WordPress Settings
- **User Registration**: Enabled in Settings > General > "Anyone can register"
- **Default User Role**: Set to "Subscriber"
- **JWT Authentication**: Properly configured in wp-config.php and .htaccess

## Authentication Flow

### Login Flow
1. User enters username/email and password
2. App sends credentials to JWT authentication endpoint
3. WordPress validates credentials and returns JWT token
4. App stores token securely and uses it for authenticated requests

### Registration Flow
1. User enters username, email, and password
2. App submits registration form to WordPress
3. WordPress creates user and sends confirmation email
4. User receives message to check email for confirmation
5. After confirming email, user can log in with credentials

### Password Reset Flow
1. User enters email address
2. App submits password reset form to WordPress
3. WordPress sends password reset email
4. User receives message to check email for reset instructions
5. After resetting password, user can log in with new credentials

## API Endpoints

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
- ✅ Password reset implemented (needs testing)
- ⬜ Email verification flow testing
- ⬜ Error handling improvements
- ⬜ UI polish and refinements

## Next Steps

1. Test the complete email verification flow
2. Improve error handling for network issues
3. Add loading indicators during authentication
4. Implement remember me functionality
5. Add unit and widget tests

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
