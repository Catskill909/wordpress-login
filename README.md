# WordPress Flutter Authentication App

> **IMPORTANT: NEVER PUSH TO GIT UNLESS EXPLICITLY REQUESTED BY THE USER**
> **ALL CODE MUST BE THOROUGHLY TESTED BEFORE COMMITTING**

A Flutter mobile application that integrates with WordPress authentication, allowing users to log in, register, and reset passwords directly within the app.

## Documentation

- [Project Plan](./project-plan.md): Detailed project plan with completed tasks and next steps
- [App README](./wordpress_app/README.md): Main project documentation
- [Documentation Directory](./docs/README.md): Additional documentation

## Features

- JWT Authentication with WordPress
- User Registration
- Password Reset
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

## Next Steps

1. Test the complete email verification flow
2. Test the password reset flow
3. Improve error handling
4. Add UI enhancements
5. Add comprehensive testing
