# WordPress Flutter Integration App

> **IMPORTANT: NEVER PUSH TO GIT UNLESS EXPLICITLY REQUESTED BY THE USER**
> **ALL CODE MUST BE THOROUGHLY TESTED BEFORE COMMITTING**

A Flutter mobile application that integrates with WordPress APIs, allowing users to log in, register, reset passwords, and interact with WordPress content directly within the app. The app serves as a proof of concept for leveraging WordPress as a backend while providing a seamless native mobile experience.

## Documentation

- [Project Plan](./project-plan.md): Detailed project plan with completed tasks and next steps
- [App README](./wordpress_app/README.md): Main project documentation
- [Documentation Directory](./docs/README.md): Additional documentation

## Features

- JWT Authentication with WordPress
- User Registration with Email Verification
- Password Reset with Email Verification Codes
- WordPress Content Integration
- User Profile Management
- Social Features (comments, likes, shares)
- Modern Material Design UI
- Clean Architecture

## Getting Started

1. Clone the repository
   ```
   git clone https://github.com/Catskill909/wordpress-login.git
   ```
2. Navigate to the app directory
   ```
   cd wordpress-login/wordpress_app
   ```
3. Install dependencies
   ```
   flutter pub get
   ```
4. Run the app
   ```
   flutter run
   ```

## Current Status

- ✅ WordPress backend is fully configured
- ✅ JWT Authentication is working correctly
- ✅ Login and logout functionality is working
- ✅ User registration is working (email verification required)
- ✅ Password reset is implemented (needs testing)
- ✅ Email verification code mechanism is working
- ✅ Profile image upload and display is working
- ⬜ WordPress content integration features

## WordPress Content Integration & Extensibility

This app now features a robust Dart view model (`WordpressPost`) for consuming the WordPress posts API. The model is designed to be extensible and highlights the versatility of WordPress as a backend for mobile apps.

### WordpressPost Model Fields (Key Features)
- id, title, content, excerpt, slug, status, link, date, modified
- author, featuredMedia, categories, tags
- format, sticky
- featuredMediaUrl (optional, for rich media integration)

This model can be easily extended to support:
- Custom fields (ACF, plugin meta)
- Comments, users, and media endpoints
- Taxonomies, custom post types, and more

### Future Development
- See [docs/README.md](./docs/README.md) for future dev notes, including:
  - Portable WordPress+Flutter stack vision
  - Plugin compatibility and extensibility
  - Advanced API features and proof-of-concept ideas

## Next Steps

1. Add additional user profile management features (update name, email, etc.)
2. Add content access features (posts, pages, custom content types)
3. Implement social features (comments, likes, shares)
4. Improve error handling for network issues
5. Add comprehensive unit and widget tests
6. Expand WordPress API integration with additional features
