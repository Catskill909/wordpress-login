# WordPress Flutter App

A modern Flutter application that integrates with a WordPress backend, featuring clean Material Design and authentication functionality.

## Project Overview

This project is a cross-platform mobile application built with Flutter that connects to a WordPress backend. It provides a seamless user experience with a focus on clean design and robust authentication.

## Features

- **Authentication**
  - User login with email/username and password
  - User registration
  - Password reset (planned)
  - JWT token-based authentication

- **Clean Architecture**
  - Separation of concerns with domain, data, and presentation layers
  - BLoC pattern for state management
  - Repository pattern for data access
  - Dependency injection with GetIt

- **Modern UI**
  - Material Design 3
  - Responsive layouts
  - Form validation
  - Loading indicators

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

## WordPress Backend Requirements

The app requires a WordPress backend with the following plugins:
- WP REST API (Core)
- JWT Authentication for WP REST API
- WP Mail SMTP (for email functionality)
- Advanced Custom Fields (optional)
- Custom Post Type UI (optional)

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- WordPress site with required plugins
- DirectAdmin email configuration

### Installation

1. Clone the repository
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Update the API endpoints in `lib/core/constants/app_constants.dart` to point to your WordPress site
4. Run the app:
   ```
   flutter run
   ```

## Next Steps

- Configure WordPress plugins
- Set up DirectAdmin email settings
- Implement content display from WordPress
- Add offline capabilities
- Enhance user profile management
