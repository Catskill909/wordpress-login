# WordPress Email Integration Plan for Flutter App

This document outlines the steps needed to implement email-based features in the Flutter app, specifically user registration with email verification and password reset functionality.

## Current Status

- ✅ WordPress backend is set up with JWT Authentication
- ✅ WP Mail SMTP is configured with login@djchucks.com
- ✅ Login and logout functionality is working in the Flutter app
- ❌ User registration endpoint is not yet available
- ❌ Password reset functionality is not yet implemented

## 1. User Registration with Email Verification

### 1.1 WordPress Configuration

1. **Install JSON API User Plugin**:
   - Go to WordPress admin > Plugins > Add New
   - Search for "JSON API User"
   - Install and activate the plugin
   - This will add the necessary endpoints for user registration

2. **Configure Email Templates**:
   - Go to WordPress admin > Settings > JSON API User (if available)
   - Configure the email verification template
   - Ensure the "From" email is set to login@djchucks.com

3. **Test Registration Endpoint**:
   - Use ReqBin or Postman to test the registration endpoint
   - Send a POST request to `https://djchucks.com/tester/wp-json/json-api-user/register`
   - Include the following JSON body:
     ```json
     {
       "username": "testuser",
       "email": "your-test-email@example.com",
       "password": "securepassword123"
     }
     ```
   - Verify that you receive a success response
   - Check that a verification email is sent to the provided email address

### 1.2 Flutter App Implementation

1. **Update API Constants**:
   - Open `lib/core/constants/app_constants.dart`
   - Update the registration endpoint to match the JSON API User plugin:
     ```dart
     static const String registerEndpoint = '$apiUrl/json-api-user/register';
     ```

2. **Update Registration Data Source**:
   - Modify the `register` method in `auth_remote_data_source.dart` to handle the response format from the JSON API User plugin

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

1. **Configure Password Reset Endpoint**:
   - The JSON API User plugin should also provide a password reset endpoint
   - Verify it's available at `https://djchucks.com/tester/wp-json/json-api-user/lost-password`

2. **Test Password Reset Endpoint**:
   - Use ReqBin or Postman to test the endpoint
   - Send a POST request with the user's email:
     ```json
     {
       "email": "your-test-email@example.com"
     }
     ```
   - Verify that a password reset email is sent to the provided address

### 2.2 Flutter App Implementation

1. **Update API Constants**:
   - Open `lib/core/constants/app_constants.dart`
   - Update the forgot password endpoint:
     ```dart
     static const String forgotPasswordEndpoint = '$apiUrl/json-api-user/lost-password';
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
