# WordPress Email Integration Plan for Flutter App

This document outlines the steps needed to implement email-based features in the Flutter app, specifically user registration with email verification and password reset functionality.

## Current Status

- ✅ WordPress backend is set up with JWT Authentication
- ✅ WP Mail SMTP is configured with login@djchucks.com
- ✅ Login and logout functionality is working in the Flutter app
- ✅ JSON API core plugin installed and activated
- ❌ JSON API User plugin installed but User controller is not activated
- ✅ Custom WordPress plugin created for registration and password reset
- ✅ Registration functionality updated to use custom plugin endpoint
- ✅ Password reset functionality updated to use custom plugin endpoint

## 1. User Registration with Email Verification

### 1.1 WordPress Configuration

1. **Install Required Plugins**: ✅
   - JSON API core plugin (installed)
   - JSON API User plugin (installed)
   - These plugins provide the necessary endpoints for user registration and password reset

2. **Configure Email Templates**:
   - Go to WordPress admin > Settings > JSON API User (if available)
   - Configure the email verification template
   - Ensure the "From" email is set to login@djchucks.com

3. **Test Registration Endpoint**: ✅
   - Use ReqBin or Postman to test the registration endpoint
   - First get a nonce: `https://djchucks.com/tester/api/get_nonce/?controller=user&method=register`
   - Then send a POST request to `https://djchucks.com/tester/api/user/register`
   - Include the following parameters in the URL or as form data:
     ```
     username=testuser
     email=your-test-email@example.com
     user_pass=securepassword123
     nonce=YOUR_NONCE_HERE
     display_name=testuser
     notify=both
     ```
   - Verify that you receive a success response
   - Check that a verification email is sent to the provided email address

### 1.2 Flutter App Implementation

1. **Update API Constants**: ✅
   - Open `lib/core/constants/app_constants.dart`
   - Update the registration endpoint to use our custom WordPress plugin endpoints:
     ```dart
     static const String registerEndpoint = '$apiUrl/wp/v2/users/register';
     static const String forgotPasswordEndpoint = '$apiUrl/wp/v2/users/lostpassword';
     ```

2. **Update Registration Data Source**: ✅
   - Modify the `register` method in `auth_remote_data_source.dart` to use our custom plugin endpoint
   - Send user registration data directly to the endpoint
   - Handle the custom response format from our plugin
   - Add proper error handling for various error scenarios
   - Update the password reset method to use our custom plugin endpoint as well

3. **Implement Registration UI**:
   - Complete the registration screen in `lib/presentation/pages/register_page.dart`
   - Add form validation for username, email, and password
   - Connect the form submission to the AuthBloc's RegisterEvent
   - Display appropriate success and error messages

4. **Add Email Verification Instructions**:
   - After successful registration, show a message instructing the user to check their email
   - Provide a way for users to request a new verification email if needed

## 2. Password Reset Functionality

### 2.1 WordPress Configuration

1. **Configure Password Reset Endpoint**: ✅
   - Our custom WordPress plugin provides a password reset endpoint
   - Available at `https://djchucks.com/tester/wp-json/wp/v2/users/lostpassword`

2. **Test Password Reset Endpoint**:
   - Use ReqBin or Postman to test the endpoint
   - Send a POST request with the user's email:
     ```json
     {
       "email": "your-test-email@example.com"
     }
     ```
   - Verify that a password reset email is sent to the provided address
   - Check that the response includes a success status and message

### 2.2 Flutter App Implementation

1. **Update API Constants**: ✅
   - Open `lib/core/constants/app_constants.dart`
   - Update the forgot password endpoint to use our custom plugin endpoint:
     ```dart
     static const String forgotPasswordEndpoint = '$apiUrl/wp/v2/users/lostpassword';
     ```

2. **Create Forgot Password Screen**:
   - Create a new file at `lib/presentation/pages/forgot_password_page.dart`
   - Implement a form with an email field
   - Add validation for the email
   - Connect to the AuthBloc to handle the password reset request

3. **Update Routes**:
   - Add a route for the forgot password screen in `lib/app/routes.dart`
   - Connect the "Forgot Password?" link on the login screen to this route

4. **Handle Password Reset Flow**:
   - After submitting the form, show a message instructing the user to check their email
   - The email will contain a link to reset their password on the WordPress site
   - After resetting their password, the user can return to the app and log in with their new credentials

## 3. Testing Plan

### 3.1 Registration Testing

1. Test registration with valid data
2. Test registration with invalid data (e.g., weak password, invalid email)
3. Test registration with an existing username or email
4. Verify that verification emails are sent and contain the correct link
5. Test the email verification process

### 3.2 Password Reset Testing

1. Test password reset with a valid email
2. Test password reset with an invalid or non-existent email
3. Verify that password reset emails are sent and contain the correct link
4. Test the password reset process
5. Verify that users can log in with their new password

## 4. Implementation Timeline

1. **Day 1**: Install and configure JSON API User plugin
2. **Day 2**: Test registration and password reset endpoints
3. **Day 3**: Implement registration screen in Flutter app
4. **Day 4**: Implement forgot password screen in Flutter app
5. **Day 5**: Test all functionality and fix any issues

## 5. Next Steps After Email Integration

Once email-based features are implemented, the next steps will be:

1. Set up Custom Post Types and Advanced Custom Fields
2. Implement content display in the Flutter app
3. Add user profile management
4. Implement offline capabilities
5. Add error handling and retry mechanisms
