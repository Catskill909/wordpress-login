# WordPress and Flutter App Architecture Plan

## 1. System Overview

This document outlines the architecture and implementation plan for a cross-platform mobile application built with Flutter that integrates with a WordPress backend. The system will provide a seamless user experience while leveraging WordPress's content management capabilities and Flutter's cross-platform development advantages.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Flutter App    │◄────┤  WordPress API  │◄────┤  WordPress CMS  │
│  (Mobile/Web)   │     │  (REST/GraphQL) │     │  (Admin Panel)  │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## 2. WordPress Backend Architecture

### 2.1 Core Components

- **WordPress Core**: Latest stable version
- **Database**: MySQL for content and user storage
- **Authentication**: JWT-based authentication system
- **API Layer**: REST API with custom endpoints
- **Media Storage**: WordPress media library with optimized delivery

### 2.2 WordPress Plugins

| Plugin | Purpose |
|--------|---------|
| WP REST API | Core API functionality |
| JWT Authentication | Secure authentication for mobile app |
| WP Mail SMTP | Email delivery via DirectAdmin |
| Advanced Custom Fields | Extended content modeling |
| Custom Post Type UI | Custom content type creation |
| WooCommerce (optional) | E-commerce functionality |
| Yoast SEO | SEO optimization |
| WP Super Cache | Performance optimization |
| Wordfence Security | Security hardening |

### 2.3 Custom Development

- Custom REST API endpoints for app-specific functionality
- Custom user roles and permissions
- Custom taxonomies and post types
- Server-side validation and business logic

## 3. Flutter App Architecture

### 3.1 Core Architecture

- **State Management**: BLoC pattern with flutter_bloc
- **Dependency Injection**: GetIt for service locator pattern
- **Navigation**: GoRouter for declarative routing
- **Network Layer**: Dio with interceptors for API communication
- **Local Storage**: Hive for persistent storage
- **Authentication**: Secure token storage with flutter_secure_storage

### 3.2 App Structure

```
lib/
├── app/
│   ├── app.dart
│   └── routes.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── blocs/
│   ├── pages/
│   └── widgets/
└── main.dart
```

### 3.3 Flutter Packages

| Package | Purpose |
|---------|---------|
| flutter_bloc | State management |
| dio | HTTP client |
| get_it | Dependency injection |
| go_router | Navigation |
| hive | Local database |
| flutter_secure_storage | Secure storage |
| json_serializable | JSON serialization |
| cached_network_image | Image caching |
| flutter_form_builder | Form handling |
| intl | Internationalization |
| flutter_dotenv | Environment configuration |
| flutter_native_splash | Splash screen |
| flutter_launcher_icons | App icons |

## 4. Integration Points

### 4.1 Authentication Flow

1. User registration via WordPress custom endpoint
2. Email verification through WordPress
3. JWT token-based authentication
4. Secure token storage on device
5. Token refresh mechanism
6. Password reset flow

### 4.2 Content Synchronization

1. Initial content loading with pagination
2. Offline content caching
3. Background synchronization
4. Delta updates for efficiency
5. Conflict resolution strategy

### 4.3 Media Handling

1. Optimized image loading with caching
2. Progressive image loading
3. Video content handling
4. File uploads to WordPress media library

## 5. Step-by-Step Implementation Plan

### Phase 1: WordPress Backend Setup (Weeks 1-2)

1. **Week 1: Core WordPress Setup**
   - Install WordPress on hosting
   - Configure database and basic settings
   - Install and configure essential plugins
   - Set up security measures (SSL, firewall)
   - Configure DirectAdmin email with WP Mail SMTP

2. **Week 2: WordPress API Development**
   - Configure REST API endpoints
   - Set up JWT authentication
   - Create custom post types and taxonomies
   - Develop custom API endpoints
   - Test API functionality

### Phase 2: Flutter App Foundation (Weeks 3-4)

3. **Week 3: Flutter Project Setup**
   - Initialize Flutter project
   - Set up project structure
   - Configure dependencies
   - Implement core architecture components
   - Create network layer with Dio

4. **Week 4: Authentication Implementation**
   - Develop registration screens
   - Implement login functionality
   - Create secure token storage
   - Build password reset flow
   - Test authentication flows

### Phase 3: Core App Functionality (Weeks 5-7)

5. **Week 5: Content Display**
   - Implement content models
   - Create repository layer
   - Build UI components for content display
   - Implement pagination and loading states
   - Add pull-to-refresh functionality

6. **Week 6: User Profile & Settings**
   - Create user profile screens
   - Implement settings functionality
   - Add theme switching capability
   - Build notification preferences
   - Implement account management

7. **Week 7: Offline Capabilities**
   - Implement local storage with Hive
   - Create synchronization service
   - Add offline mode detection
   - Build background sync functionality
   - Test offline scenarios

### Phase 4: Refinement and Launch (Weeks 8-10)

8. **Week 8: UI/UX Polishing**
   - Refine animations and transitions
   - Implement responsive layouts
   - Add accessibility features
   - Optimize performance
   - Conduct usability testing

9. **Week 9: Testing & Bug Fixing**
   - Conduct unit and widget testing
   - Perform integration testing
   - Fix identified bugs
   - Optimize app size and performance
   - Test on multiple devices

10. **Week 10: Deployment Preparation**
    - Prepare app store assets
    - Configure app signing
    - Create marketing materials
    - Finalize documentation
    - Submit to app stores

## 6. Maintenance and Future Enhancements

- Regular WordPress and plugin updates
- Flutter framework updates
- Performance monitoring and optimization
- User feedback collection and analysis
- Feature expansion based on analytics
- A/B testing for UI improvements
- Push notification implementation
- Analytics integration
- Social media sharing capabilities
- Deep linking functionality

## 7. Detailed Implementation Steps

### WordPress Backend Implementation

#### Step 1: WordPress Installation and Setup
1. Download WordPress from wordpress.org
2. Create MySQL database and user
3. Upload WordPress files to hosting
4. Run the installation wizard
5. Configure basic settings (site title, admin user, etc.)
6. Set up permalinks (use post name structure)
7. Install and activate required plugins:
   - JWT Authentication for WP REST API
   - WP Mail SMTP
   - Advanced Custom Fields
   - Custom Post Type UI
   - Wordfence Security
   - WP Super Cache

#### Step 2: WordPress Security Configuration
1. Install SSL certificate
2. Configure Wordfence firewall settings
3. Set up strong password policy
4. Implement login attempt limitations
5. Configure file permissions
6. Set up regular backups
7. Disable file editing in wp-config.php

#### Step 3: Email Configuration with DirectAdmin ✅
1. Create email account in DirectAdmin ✅
   - Created login@djchucks.com for app authentication emails
2. Install WP Mail SMTP plugin ✅
3. Configure SMTP settings: ✅
   - SMTP Host: mail.yourdomain.com
   - SMTP Port: 587 (TLS) or 465 (SSL)
   - Encryption: TLS or SSL
   - Authentication: On
   - Username: login@djchucks.com
   - Password: [email password]
4. Test email delivery ✅ (Emails successfully delivered)
5. Resolving DMARC errors:
   - Add SPF record to DNS:
     ```
     v=spf1 a mx ip4:YOUR_SERVER_IP ~all
     ```
   - Add DKIM record (generate in DirectAdmin)
   - Add DMARC record:
     ```
     v=DMARC1; p=none; rua=mailto:login@djchucks.com
     ```

#### Step 4: Custom Post Types and Taxonomies
1. Use Custom Post Type UI to create necessary post types:
   - App Content
   - User Profiles
   - Notifications
2. Create custom taxonomies:
   - Content Categories
   - Content Tags
3. Configure Advanced Custom Fields for each post type

#### Step 5: REST API Configuration
1. Configure JWT Authentication: ✅
   - Add secret key to wp-config.php ✅
   - Configure .htaccess for CORS support ✅
   - Test JWT Authentication endpoint ✅
2. Create custom endpoints in functions.php:
   - User registration endpoint
   - Profile management endpoint
   - Content synchronization endpoint
3. Set up proper authentication for endpoints
4. Implement rate limiting for API requests

### Flutter App Implementation

#### Step 1: Flutter Project Setup
1. Install Flutter SDK
2. Set up development environment (Android Studio/VS Code)
3. Create new Flutter project:
   ```
   flutter create --org com.yourcompany wordpress_app
   ```
4. Configure app identifier and display name
5. Set up version control (Git)

#### Step 2: Project Structure and Dependencies
1. Organize project structure (follow 3.2 App Structure)
2. Add dependencies to pubspec.yaml:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_bloc: ^8.1.3
     dio: ^5.3.2
     get_it: ^7.6.0
     go_router: ^10.1.2
     hive: ^2.2.3
     hive_flutter: ^1.1.0
     flutter_secure_storage: ^8.0.0
     json_annotation: ^4.8.1
     cached_network_image: ^3.2.3
     flutter_form_builder: ^9.1.0
     intl: ^0.18.1
     flutter_dotenv: ^5.1.0

   dev_dependencies:
     flutter_test:
       sdk: flutter
     build_runner: ^2.4.6
     json_serializable: ^6.7.1
     hive_generator: ^2.0.0
     flutter_native_splash: ^2.3.2
     flutter_launcher_icons: ^0.13.1
   ```
3. Run `flutter pub get`

#### Step 3: Core Architecture Implementation
1. Set up environment configuration (dev/prod)
2. Implement network layer with Dio:
   - Base API client
   - Request/response interceptors
   - Error handling
3. Configure dependency injection with GetIt
4. Set up navigation with GoRouter
5. Implement local storage with Hive

#### Step 4: Authentication Implementation
1. Create authentication models:
   - User model
   - Auth tokens model
2. Implement authentication repository:
   - Registration
   - Login
   - Token refresh
   - Password reset
3. Create authentication BLoC:
   - Auth events
   - Auth states
   - Auth logic
4. Build authentication UI:
   - Login screen
   - Registration screen
   - Password reset screen

#### Step 5: Content Management
1. Create content models
2. Implement content repository:
   - Fetch content
   - Cache content
   - Sync content
3. Build content BLoC
4. Create content UI components:
   - Content list
   - Content detail
   - Content search

#### Step 6: User Profile and Settings
1. Implement user profile repository
2. Create settings storage service
3. Build profile and settings UI:
   - Profile screen
   - Edit profile screen
   - Settings screen
   - Theme selection

#### Step 7: Offline Capabilities
1. Implement connectivity monitoring
2. Create synchronization service
3. Set up background fetch
4. Implement conflict resolution
5. Build offline mode UI indicators

#### Step 8: WordPress and Flutter Integration
1. Implement API service in Flutter:
   - Create WordPress API client class
   - Implement authentication endpoints
   - Create content fetching methods
   - Build media handling utilities
2. Test API integration:
   - Test authentication flow
   - Verify content synchronization
   - Test media uploads and downloads
3. Implement error handling:
   - Network error handling
   - API error responses
   - Retry mechanisms
4. Optimize API performance:
   - Implement request caching
   - Use efficient pagination
   - Optimize payload size

#### Step 9: Testing and Deployment
1. Write unit tests for repositories and BLoCs
2. Create widget tests for UI components
3. Perform integration testing
4. Configure CI/CD pipeline
5. Prepare app for release:
   - Generate app icons
   - Create splash screen
   - Write app store descriptions
   - Take screenshots
6. Build release versions:
   ```
   flutter build apk --release
   flutter build ios --release
   ```
7. Submit to app stores

## 8. WordPress and Flutter Integration Details

### 8.1 WordPress API Configuration for Flutter

#### JWT Authentication Setup
```php
// Add to wp-config.php
define('JWT_AUTH_SECRET_KEY', 'your-secret-key-here');
define('JWT_AUTH_CORS_ENABLE', true);
```

#### CORS Configuration in .htaccess
```
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{HTTP:Authorization} ^(.*)
RewriteRule ^(.*) - [E=HTTP_AUTHORIZATION:%1]
SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1

Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "POST, GET, OPTIONS, PUT, DELETE"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
</IfModule>
```

#### Custom API Endpoint Example
```php
// Add to functions.php or custom plugin
add_action('rest_api_init', function () {
  register_rest_route('app/v1', '/content', [
    'methods' => 'GET',
    'callback' => 'get_app_content',
    'permission_callback' => function () {
      return current_user_can('read');
    }
  ]);
});

function get_app_content($request) {
  $args = [
    'post_type' => 'app_content',
    'posts_per_page' => $request->get_param('per_page') ?: 10,
    'paged' => $request->get_param('page') ?: 1,
  ];

  $posts = get_posts($args);
  $data = [];

  foreach ($posts as $post) {
    $data[] = [
      'id' => $post->ID,
      'title' => $post->post_title,
      'content' => $post->post_content,
      'date' => $post->post_date,
      'featured_image' => get_the_post_thumbnail_url($post->ID, 'full'),
      'custom_fields' => get_fields($post->ID),
    ];
  }

  return $data;
}
```

### 8.2 Flutter WordPress API Integration

#### API Client Implementation
```dart
// lib/core/network/wordpress_api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WordPressApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final String baseUrl;

  WordPressApiClient({
    required this.baseUrl,
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  }) : _dio = dio, _secureStorage = secureStorage {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(_authInterceptor());
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Handle token refresh here
        }
        return handler.next(error);
      },
    );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/wp-json/jwt-auth/v1/token',
        data: {
          'username': username,
          'password': password,
        },
      );

      final token = response.data['token'];
      await _secureStorage.write(key: 'auth_token', value: token);

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        '/wp-json/wp/v2/users/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getContent({int page = 1, int perPage = 10}) async {
    try {
      final response = await _dio.get(
        '/wp-json/app/v1/content',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return Exception(error.response?.data['message'] ?? 'Unknown error');
      }
      return Exception('Network error: ${error.message}');
    }
    return Exception('Unknown error: $error');
  }
}
```

### 8.3 Flutter Authentication UI Implementation

#### Login Screen Example
```dart
// lib/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../domain/blocs/auth/auth_bloc.dart';
import '../../domain/blocs/auth/auth_event.dart';
import '../../domain/blocs/auth/auth_state.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is Authenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormBuilderTextField(
                    name: 'username',
                    decoration: const InputDecoration(
                      labelText: 'Username or Email',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'password',
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(6),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            if (_formKey.currentState?.saveAndValidate() ?? false) {
                              final data = _formKey.currentState!.value;
                              context.read<AuthBloc>().add(
                                    LoginRequested(
                                      username: data['username'],
                                      password: data['password'],
                                    ),
                                  );
                            }
                          },
                    child: state is AuthLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: const Text('Don\'t have an account? Register'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## 9. Implementation Progress

### Completed Tasks

#### Flutter App Core Implementation
1. ✅ Created Flutter project with proper structure
2. ✅ Set up project dependencies
3. ✅ Implemented core architecture components:
   - ✅ Network layer with Dio
   - ✅ Error handling with custom exceptions
   - ✅ Secure storage service
   - ✅ Dependency injection with GetIt
4. ✅ Implemented authentication:
   - ✅ User entity and model
   - ✅ Authentication repository
   - ✅ Authentication BLoC
   - ✅ Login functionality (tested and working)
   - ✅ Logout functionality (tested and working)
   - 🔄 Registration screen (UI implemented, endpoint pending)
5. ✅ Set up navigation with GoRouter
6. ✅ Implemented Material Design theme

#### WordPress Backend Setup
1. ✅ Installed WordPress
2. ✅ Installed required plugins:
   - ✅ WP REST API (Core)
   - ✅ JWT Authentication for WP REST API (tested and working)
   - ✅ WP Mail SMTP (configured with login@djchucks.com)
   - ✅ Advanced Custom Fields
   - ✅ Custom Post Type UI
   - ✅ Wordfence Security
   - ✅ WP Super Cache
   - ✅ JSON API (core plugin)
   - ✅ JSON API User (for registration and password reset)

### Current Tasks

1. ✅ Configure WordPress plugins:
   - ✅ JWT Authentication setup
   - ✅ CORS configuration
   - ✅ JSON API and JSON API User plugins installed
   - 🔄 Custom API endpoints
2. ✅ Set up DirectAdmin email with WP Mail SMTP (Working with login@djchucks.com, minor DMARC issues to resolve)
3. ✅ Implement basic authentication in Flutter app:
   - ✅ Login functionality
   - ✅ Logout functionality
   - ✅ Password visibility toggle with eye icon

### Next Tasks

1. ✅ Test WordPress API endpoints with Flutter app (JWT Authentication tested and working)
2. 🔄 Implement email-based features:
   - ✅ Test JSON API User registration endpoint (working at `/?json=json-api-user/register`)
   - ✅ Update Flutter app constants to use the correct JSON API User endpoints
   - ✅ Update the registration and password reset methods to use the JSON API User endpoints
   - 🔄 Test the registration functionality in the app
   - 🔄 Test the password reset functionality in the app
3. Set up Custom Post Types and Advanced Custom Fields
4. Implement content display in Flutter app
5. Add user profile management
6. Implement offline capabilities
7. Add error handling and retry mechanisms

## 10. Conclusion and Next Steps

This comprehensive plan outlines the architecture, components, and implementation steps for building a WordPress-powered Flutter application. By following this structured approach, development teams can efficiently create a robust, scalable, and maintainable cross-platform mobile application that leverages WordPress's powerful content management capabilities.

### Key Success Factors

1. **Proper Planning**: Following this detailed plan will ensure all aspects of the project are considered before development begins.

2. **Modular Architecture**: The proposed architecture emphasizes separation of concerns, making the codebase easier to maintain and extend.

3. **Security First**: Security considerations are integrated throughout the plan, from WordPress configuration to Flutter implementation.

4. **Performance Optimization**: The plan includes specific steps for optimizing both the WordPress backend and Flutter app performance.

5. **User Experience Focus**: The implementation prioritizes a smooth, responsive user experience with offline capabilities.

### Next Steps After Initial Launch

1. **Analytics Implementation**: Integrate analytics to track user behavior and app performance.

2. **A/B Testing**: Implement A/B testing for UI/UX improvements based on user data.

3. **Feature Expansion**: Plan for additional features based on user feedback and business requirements.

4. **Performance Monitoring**: Set up continuous performance monitoring and optimization.

5. **Regular Updates**: Establish a schedule for regular updates to both WordPress and Flutter components.

By following this plan, development teams can create a high-quality WordPress-powered Flutter application that meets business requirements while providing an excellent user experience.
